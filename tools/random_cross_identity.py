"""Conservative execution identity for optional exploration admission.

Paths are provenance, never identity by themselves. Missing dependency evidence
disables deduplication; it does not prevent an ordinary comparison.
"""

import os
from pathlib import Path
import platform
import re
import shutil
import subprocess
import sys

import random_cross_evidence as evidence
import suite_results


def environment():
    # Record only a digest: environment variables can contain credentials.
    # platform.platform() lazily imports plistlib on macOS. Resolve it before
    # inventorying modules so our own snapshot does not appear as input drift.
    platform_name = platform.platform()
    modules = {}
    for module in list(sys.modules.values()):
        name = getattr(module, '__file__', None)
        if name:
            path = Path(name).resolve()
            modules[str(path)] = evidence.sha(path) if path.is_file() else 'MISSING'
    return {'variables_sha256': evidence.digest(dict(os.environ)),
            'platform': platform_name, 'machine': platform.machine(),
            'python': sys.version, 'python_binary_sha256': evidence.sha(sys.executable),
            'python_modules_sha256': modules,
            'working_directory_sha256': evidence.digest(str(Path.cwd().resolve()))}


def command_version(executable, flag):
    result = subprocess.run([str(executable), flag], capture_output=True, text=True,
                            errors='replace', timeout=15)
    if result.returncode:
        raise ValueError('cannot identify simulator: '+str(executable))
    return (result.stdout or result.stderr).strip()


def external_build(simulator, executable):
    resolved = shutil.which(str(executable))
    if not resolved:
        raise ValueError('cannot find '+simulator+' executable')
    path = Path(resolved).resolve()
    build = {'executable': str(path), 'binary_sha256': evidence.sha(path), 'commit': None}
    companions = []
    if simulator == 'icarus':
        companion = path.parent/'vvp'
        companions.append(companion)
        installed = path.parent.parent/'lib/ivl'
        if installed.is_dir():
            companions.extend(p for p in installed.rglob('*') if p.is_file()
                              and (p.name in ('ivl', 'ivlpp') or p.suffix in ('.tgt', '.vpi', '.conf', '.so', '.dylib')))
    else:
        roots = [path.parent]
        if os.environ.get('VERILATOR_ROOT'):
            roots.append(Path(os.environ['VERILATOR_ROOT'])/'bin')
        for root in roots:
            companions.extend(p for p in (root/'verilator_bin', root/'verilator_bin_dbg') if p.is_file())
        if os.environ.get('VERILATOR_BIN'):
            selected = shutil.which(os.environ['VERILATOR_BIN'])
            if selected:
                companions.append(Path(selected))
    build['companions'] = {str(p.resolve()): evidence.sha(p) for p in companions}
    build['version'] = command_version(path, '-V' if simulator == 'icarus' else '--version')
    if simulator == 'icarus':
        build['runtime_version'] = command_version(path.parent/'vvp', '-V')
    if (evidence.sha(path) != build['binary_sha256']
            or any(evidence.sha(name) != digest for name, digest in build['companions'].items())):
        raise ValueError('simulator changed while identifying its build')
    return build


def dependencies(builds, extra=(), declared_complete=False):
    files, unresolved = {}, []
    environment()  # Resolve platform's lazy imports before discovering DSOs.
    pending = [Path(build['executable']) for build in builds.values()] + [Path(sys.executable)]
    pending.extend(Path(module.__file__) for module in list(sys.modules.values())
                   if getattr(module, '__file__', None) and Path(module.__file__).suffix in ('.so', '.dylib', '.pyd'))
    for build in builds.values():
        pending.extend(Path(name) for name in build.get('companions', {}))
    pending.extend(Path(name).resolve() for name in extra)
    explicit = {str(Path(name).resolve()) for name in extra}
    if any(os.environ.get(name) for name in ('LD_PRELOAD', 'LD_LIBRARY_PATH', 'DYLD_INSERT_LIBRARIES',
                                             'DYLD_LIBRARY_PATH', 'DYLD_FRAMEWORK_PATH')):
        unresolved.append('dynamic loader overrides require an explicit dependency closure')
    visited = set()
    system = platform.system()
    os_build = None
    if system == 'Darwin':
        os_build = subprocess.run(['sw_vers'], capture_output=True, text=True, timeout=5,
                                  check=True).stdout.strip()
    while pending:
        path = pending.pop().resolve()
        if str(path) in visited:
            continue
        visited.add(str(path))
        if not path.is_file():
            unresolved.append(str(path)); continue
        files[str(path)] = evidence.sha(path)
        # Explicit files can also be non-executable runtime resources.
        try:
            if system == 'Darwin':
                result = subprocess.run(['otool', '-L', str(path)], capture_output=True,
                                        text=True, timeout=10)
                names = [line.strip().split(' (', 1)[0] for line in result.stdout.splitlines()[1:]]
                if result.returncode and str(path) not in explicit:
                    unresolved.append(str(path)+': not an inspectable Mach-O binary')
                for name in names:
                    if name.startswith('@loader_path/'):
                        name = str(path.parent/name.removeprefix('@loader_path/'))
                    if name.startswith(('/usr/lib/', '/System/Library/')) and not Path(name).exists():
                        continue  # dyld shared cache is identified by the exact OS build.
                    if name.startswith('@'):
                        unresolved.append(name)
                    else:
                        pending.append(Path(name))
            elif system == 'Linux':
                result = subprocess.run(['ldd', str(path)], capture_output=True, text=True, timeout=10)
                if result.returncode and str(path) not in explicit:
                    unresolved.append(str(path)+': dependency discovery failed')
                for line in result.stdout.splitlines():
                    if 'not found' in line:
                        unresolved.append(line.strip())
                    match = re.search(r'(?:=>\s*)?(/\S+)\s+\(', line)
                    if match:
                        pending.append(Path(match[1]))
            else:
                unresolved.append('automatic dependency discovery unavailable')
        except (OSError, subprocess.SubprocessError) as error:
            unresolved.append(type(error).__name__)
    # Icarus loads compiler backends/configuration; Verilator invokes a complete
    # C++ toolchain. ldd/otool alone cannot establish their complete closure.
    external = any(name != 'kirimasim' for name in builds)
    if external and not declared_complete:
        unresolved.append('external compiler/runtime/toolchain closure not declared complete')
    # A caller may supply the unresolved @rpath/backend resources explicitly,
    # but must attest completeness. Keep discovery warnings in the evidence.
    complete = (bool(files) and all(Path(name).is_file() for name in explicit)
                and (not unresolved or (declared_complete and bool(explicit))))
    return {'files': files, 'os_build': os_build, 'discovery_warnings': sorted(set(unresolved)),
            'declared_complete': declared_complete, 'complete': complete}


def unchanged(inventory):
    try:
        return all(Path(name).is_file() and evidence.sha(name) == digest
                   for name, digest in inventory['files'].items())
    except OSError:
        return False


def execution(manifest, records, sources, builds, inventory, options):
    value = {'manifest': manifest, 'inputs': records, 'sources_sha256': sources,
             'runner_sha256': {sim: suite_results.runner_digest(sim) for sim in builds},
             'builds': builds, 'dependencies': inventory, 'options': options,
             'environment': environment(), 'temporary_directory_policy': 'fresh-empty-per-case@1'}
    reasons = []
    if not inventory['complete']:
        reasons.append('dependency evidence incomplete')
    if set(builds) != {'kirimasim'}:
        reasons.append('generated external simulation binaries are identified only after compilation; always execute')
    return {'sha256': evidence.digest(value), 'details': value,
            'reusable_identity': not reasons, 'non_reuse_reasons': reasons}
