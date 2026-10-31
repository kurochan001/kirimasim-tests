"""Independent lexical environments, formal argument conversion and integer bit planes."""

from pathlib import Path
import re
import sys
import unittest

sys.path.insert(0,str(Path(__file__).resolve().parent.parent/'generators'))
import interaction_ifimport as cases


def bind(row):
    base=int(row[0]); packages={}
    for suffix,delta,tag,op in [('a',0,11,'invert'),('b',1,23,'xor3')]:
        word={'width':base+delta,'two_state':row[1]=='bit'}
        packages[suffix]={'BASE':base+delta,'MARK':tag,'raw_t':{'width':base+delta,'two_state':False},
                          'word_t':word,'encode':{'formal':word,'result':word,'op':op}}
    original=packages[row[3]]
    bridge={name:original[name] for name in ('BASE','MARK','raw_t','word_t','encode')}
    environment=dict(bridge if row[4]=='export' else original)
    caller={'BASE':base+3,'MARK':99,'LOW':max(1,base//2),'word_t':{'width':1,'two_state':True}}
    target={'W':environment['BASE'],'TAG':environment['MARK']}
    guard=dict(target)
    if row[6]=='narrow':target['W']=caller['LOW']
    if row[6]=='wide':target.update(W=caller['BASE'],TAG=caller['MARK'])
    return environment,caller,target,guard,original


def planes(row):
    width=int(row[0])+2; packet=int(row[0])+(row[3]=='b'); mask=2**width-1
    for phase in range(11):
        data=[]
        for role in (0,1):
            value=(sum(2**i for i in range(width) if (role*width+i+1)//2**phase%2)
                   if phase<9 else mask*(phase-9))
            data.append((value,0,0))
        yield f'k{phase}',data
    if row[2]!='known':
        for phase,position in enumerate((0,packet-1,packet//2,width-1)):
            data=[]; unknown=2**position
            for role in (0,1):
                value=sum(2**i for i in range(width) if (role*width+i+1)//2**phase%2)&~unknown
                data.append((value,unknown if row[2]=='x' else 0,unknown if row[2]=='z' else 0))
            yield f'u{phase}',data


def convert(value,dtype):
    v,x,z=value; mask=2**dtype['width']-1
    return v&mask,0 if dtype['two_state'] else x&mask,0 if dtype['two_state'] else z&mask


def show(value,width):
    v,x,z=value
    return ''.join('x' if x>>i&1 else 'z' if z>>i&1 else str(v>>i&1) for i in reversed(range(width)))


def function_call(function,actual):
    v,x,z=convert(actual,function['formal']);width=function['formal']['width'];mask=2**width-1
    unknown=x|z
    result=((mask^v) if function['op']=='invert' else (v^3))&mask&~unknown,unknown,0
    return convert(result,function['result'])


def interpret(row):
    env,caller,target,guard,_=bind(row);packet=env['raw_t']['width'];raw_width=int(row[0])+2;lines=[]
    for label,raws in planes(row):
        for role,parameters,raw in zip(('target','guard'),(target,guard),raws):
            incoming=convert(raw,env['raw_t']);typed=convert(incoming,env['word_t'])
            stored=function_call(env['encode'],incoming);width=parameters['W'];tag=parameters['TAG']
            v,x,z=convert(stored,{'width':width,'two_state':False})
            echo=((v^tag)&(2**width-1)&~(x|z),x|z,0)
            lines += [f'{label} {role} raw={show(raw,raw_width)} incoming={show(incoming,packet)} '
                      f'typed={show(typed,packet)} stored={show(stored,packet)} echo={show(echo,width)}',
                      f'{label} {role} W={width} TAG={tag} bits={packet},{packet},{packet},{width}']
        lines.append(f"{label} caller BASE={caller['BASE']} MARK={caller['MARK']} bits=1")
    return '\n'.join(lines)+'\n'


class InterfaceHeaderImport(unittest.TestCase):
    def test_all_1296_rows_match_independent_environments_and_formal_conversion(self):
        self.assertEqual(len(cases.MODEL.rows()),1296)
        for row in cases.MODEL.rows():self.assertEqual(cases.reference(row),interpret(row),row)

    def test_selection_keeps_all_pairs_triples_and_six_mandatory_cases(self):
        selected=cases.MODEL.select();self.assertEqual(len(selected),36)
        targets={t for row in selected for t in cases.MODEL.targets(row)}
        self.assertEqual(targets,cases.MODEL.universe())
        self.assertEqual(sum(len(t)==2 for t in targets),183)
        self.assertEqual(sum(len(t)==3 for t in targets),78)
        self.assertTrue(set(cases.MODEL.anchors)<=set(selected))

    def test_defaults_and_actual_arguments_bind_in_different_lexical_scopes(self):
        row=('33','logic','known','b','wildcard','ansi','defaults')
        env,caller,target,guard,original=bind(row)
        self.assertEqual(target,{'W':34,'TAG':23});self.assertEqual(caller['BASE'],36)
        self.assertEqual(bind((*row[:6],'narrow'))[2],{'W':16,'TAG':23})
        self.assertEqual(bind((*row[:6],'wide'))[2],{'W':36,'TAG':99})
        self.assertEqual(bind((*row[:6],'wide'))[3],guard)
        self.assertIs(env['word_t'],original['encode']['formal'])
        self.assertNotEqual(env['word_t'],caller['word_t'])

    def test_export_and_both_direct_import_forms_preserve_original_declaration_identity(self):
        for row in cases.MODEL.anchors:
            for mode in ('wildcard','explicit','export'):
                variant=(*row[:4],mode,*row[5:]);env,caller,t,g,original=bind(variant)
                for item in ('raw_t','word_t','encode'):self.assertIs(env[item],original[item])
                self.assertEqual(cases.reference(row),interpret(variant))
                if mode=='export':
                    text='\n'.join(cases.packages(variant))
                    for item in ('BASE','MARK','raw_t','word_t','encode'):
                        self.assertIn(f'import pkg_{row[3]}::{item};',text)

    def test_262_raw_bit_histories_and_their_complements_are_all_distinct(self):
        row=('129','logic','known','b','wildcard','ansi','wide');width=131
        banks=[[],[]]
        for label,raw in planes(row):
            for role in (0,1):banks[role].append(show(raw[role],width))
        histories=[history for bank in banks for history in zip(*bank)]
        flipped=[tuple('1' if b=='0' else '0' for b in history) for history in histories]
        self.assertEqual(len(set(histories+flipped)),524)
        self.assertEqual(len(set(histories)),262)

    def test_conversion_happens_before_package_operation_and_unsigned_resize(self):
        row=('129','bit','z','a','explicit','nonansi','wide')
        env,*_=bind(row);unknown=(0,0,1)
        self.assertEqual(show(function_call(env['encode'],unknown),129),'1'*129)
        logical=bind((row[0],'logic',*row[2:]))[0]
        self.assertTrue(show(function_call(logical['encode'],unknown),129).endswith('x'))
        text=interpret(('129','logic','z','b','export','nonansi','wide'))
        msb=next(line for line in text.splitlines() if line.startswith('u1 target raw='))
        self.assertRegex(msb,r'echo=00x[01x]+$')

    def test_discarded_unknown_bit_does_not_poison_any_retained_value(self):
        for row in cases.MODEL.select():
            if row[2]=='known':continue
            for line in interpret(row).splitlines():
                if line.startswith('u3 ') and ' incoming=' in line:
                    retained=line.split(' incoming=',1)[1]
                    self.assertNotRegex(retained,r'[xz]')

    def test_ansi_nonansi_and_guard_instance_defaults_remain_independent(self):
        for row in cases.MODEL.anchors:
            variant=(*row[:5],'ansi' if row[5]=='nonansi' else 'nonansi',row[6])
            self.assertEqual(cases.reference(row),interpret(variant))
            for override in ('defaults','narrow','wide'):
                other=(*row[:6],override)
                guard=[line for line in interpret(other).splitlines() if ' guard ' in line]
                self.assertEqual(guard,[line for line in interpret(row).splitlines() if ' guard ' in line])

    def test_sources_render_and_fourstate_flags_follow_raw_and_converted_observations(self):
        import common
        for row in cases.MODEL.select():
            case=cases.make_case(row);common.render(case,cases.NAME,cases.VERSION,cases.CHAPTER,'spec')
            words=re.findall(r'(?:raw|incoming|typed|stored|echo)=([01xz]+)',case.expected)
            self.assertEqual(case.fourstate,any('x' in word or 'z' in word for word in words))
            self.assertEqual(len(case.expected.splitlines()),55 if row[2]=='known' else 75)
            self.assertIn("W'(stored) ^ W'(TAG)",case.body)


if __name__=='__main__':unittest.main()
