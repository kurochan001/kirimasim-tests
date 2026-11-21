"""Complete the inherited keyword sets of five begin_keywords modes.

The existing keywords generator tests each edition's additions. These cases
test the inherited words in that edition, plus the full noconfig set, so
the old and new cases together cover each cumulative set of 22.14.3,
22.14.4, 22.14.6, 22.14.7 and 22.14.8. Existing generated tests are untouched.
"""

from common import Case
import keywords

NAME = "keywords_inherited"
VERSION = 1
CHAPTER = 22

TARGETS = {
    "1364-2001": "22.14.3",
    "1364-2001-noconfig": "22.14.4",
    "1800-2005": "22.14.6",
    "1800-2009": "22.14.7",
    "1800-2012": "22.14.8",
}
NO_CONFIG = set("cell config design endconfig incdir include instance liblist library use".split())
FULL_COUNTS = {"1364-1995": 102, "1364-2001": 123, "1364-2005": 124,
               "1800-2005": 221, "1800-2009": 244, "1800-2012": 248}
NEW_COUNTS = {"1364-2001": 102, "1364-2001-noconfig": 113,
              "1800-2005": 124, "1800-2009": 221, "1800-2012": 244}

# Filled only for observed acceptances; the specification still requires
# rejection. The remark is emitted as one short body comment to avoid a
# wrapped comment accidentally becoming a tool directive.
ACCEPTED_BY_5054 = {("1800-2012", "global")}
UNSUPPORTED_BY_5054 = {(version, "include")
                       for version in ("1800-2005", "1800-2009", "1800-2012")}


def full_sets() -> dict[str, set[str]]:
    result = {}
    accumulated = set()
    for version in keywords.ADDED:
        added = set(keywords.added(version))
        assert len(added) == len(keywords.added(version))
        assert not accumulated & added, version
        accumulated |= added
        result[version] = set(accumulated)
    result["1364-2001-noconfig"] = result["1364-2001"] - NO_CONFIG
    return result


def new_words(version: str) -> list[str]:
    full = full_sets()[version]
    old = set() if version.endswith("-noconfig") else set(keywords.added(version))
    return sorted(full - old)


def check_model() -> None:
    full = full_sets()
    assert {version: len(full[version]) for version in FULL_COUNTS} == FULL_COUNTS
    assert NO_CONFIG <= set(keywords.added("1364-2001"))
    assert len(NO_CONFIG) == 10
    assert full["1800-2012"] == set(keywords.annex_b())
    assert {version: len(new_words(version)) for version in TARGETS} == NEW_COUNTS
    for version in TARGETS:
        inherited = set(new_words(version))
        old = set() if version.endswith("-noconfig") else set(keywords.added(version))
        assert not inherited & old
        assert inherited | old == full[version]
    assert sum(NEW_COUNTS.values()) == 804


def case(version: str, word: str) -> Case:
    name = f"test_gen_kw_inherited_{version.replace('-', '_')}_{word}"
    clause = TARGETS[version]
    origin = ("The noconfig set retains this word after removing only the ten "
              "configuration words of 22.14.4."
              if version.endswith("-noconfig") else
              "This word is inherited from an earlier edition, rather than being "
              "one of the additions of the selected edition.")
    remark = ("// The 5.054 release of Verilator accepts this declaration.\n"
              if (version, word) in ACCEPTED_BY_5054 else "")
    if (version, word) in UNSUPPORTED_BY_5054:
        remark = ("// An unsupported-feature error accompanies the syntax error in\n"
                  "// the 5.054 release of Verilator; it is not registered as an oracle.\n")
    return Case(
        name=name,
        description=f"`{word}` remains reserved in the cumulative {version} keyword set "
                    "and cannot name a reg",
        lrm=f"{clause} 22.14 5.6",
        comment=f"IEEE 1800-2023 {clause} defines the complete keyword set selected by "
                f"begin_keywords {version}. {origin} The word {word} therefore cannot "
                "be used as an unescaped simple identifier (5.6). The selected mode "
                "surrounds a plain reg declaration whose only error is its reserved "
                "variable name. A conforming implementation reports that use; an "
                "implementation that forgets this surviving keyword accepts it.",
        body=remark + f'`begin_keywords "{version}"\n'
             f"module {name};\n"
             f"  reg {word};  // illegal\n"
             "endmodule\n"
             "`end_keywords\n",
        expected="",
        should_fail_because=f"{word} is reserved in the complete {version} keyword set "
                            f"of {clause}, so it cannot be an unescaped variable name",
        unregistered=("verilator",) if (version, word) in UNSUPPORTED_BY_5054 else ())


def cases() -> list[Case]:
    check_model()
    return [case(version, word) for version in TARGETS for word in new_words(version)]
