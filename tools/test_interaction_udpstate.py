"""Independent transition-table instances driven by separate data and clock events."""

from pathlib import Path
import re
import sys
import unittest

sys.path.insert(0,str(Path(__file__).resolve().parent.parent/'generators'))
import interaction_udpstate as cases


def frames(row):
    w=int(row[0]); mask=2**w-1

    def known(phase):
        number=sum(2**i for i in range(w) if (i+1)//2**phase%2) if phase<8 else mask*(phase-8)
        return f'{number:0{w}b}'

    packets=[(f'k{p}',known(p)) for p in range(10)]
    if row[2]!='known':
        for p in range(3):
            packets.append((f'prime{p}','1'*w))
            data=list(known(p))
            locations=(0,w-1,(w//2+p)%w)
            for index in locations:
                data[-index-1]=row[2]
            packets.append((f'u{p}',''.join(data)))
    packets.append(('recover','1'*w))
    for label,data in packets:
        for parity in (0,1):
            enabled={i for i in range(w) if row[6]=='shared' or i%2==parity}
            yield f'{label}_{parity}',data,'target',enabled
    for p in range(10):
        yield f'guard{p}',known(p),'guard',set()


class Instance:
    def __init__(self,category,idle,data,active):
        self.state={0:'0',1:'1',2:'x'}[category]
        self.clock,self.data,self.active=idle,data,active

    def event(self,clock,data):
        # Interpret the table, rather than directly copying the expected sample.
        data='x' if data=='z' else data
        if (clock,data)==(self.clock,self.data):
            return
        transition=(self.clock,clock)
        clock_changed=self.clock!=clock
        data_changed=self.data!=data
        rows=[((str(1-int(self.active)),self.active),'0','0'),
              ((str(1-int(self.active)),self.active),'1','1'),
              (('?',str(1-int(self.active))),'?','-'),(None,'*','-')]
        matches=[]
        for edge,input_pattern,next_state in rows:
            if edge is None:
                matched=data_changed
            else:
                matched=clock_changed and all(p=='?' or p==v for p,v in zip(edge,transition))
                matched=matched and (input_pattern=='?' or input_pattern==data)
            if matched:
                matches.append(self.state if next_state=='-' else next_state)
        assert len(set(matches))<=1
        self.state=matches[0] if matches else 'x'
        self.clock,self.data=clock,data


def interpret(row):
    w,offset=int(row[0]),int(row[4]); idle='0' if row[3]=='rise' else '1'; active=str(1-int(idle))
    target=[Instance((i+offset)%3,idle,'0',active) for i in range(w)]
    guard=[Instance((i+offset+1)%3,idle,'1',active) for i in range(w)]
    raw,source='0'*w,'0'*w; clocks=[idle]*w; gc=idle

    def observe(label):
        return (f'{label} raw={raw} source={source} clock={"".join(reversed(clocks))} guard_clk={gc} '
                f'q={"".join(obj.state for obj in reversed(target))} '
                f'guard={"".join(obj.state for obj in reversed(guard))}')

    lines=[observe('initial'),'initial codes='+''.join(str((i+offset)%3) for i in reversed(range(w)))]
    for label,raw,owner,enabled in frames(row):
        source=''.join('0' if row[1]=='bit' and c in 'xz' else c for c in raw)
        target_data=list(reversed(source)); guard_data=['1' if c=='0' else '0' if c=='1' else 'x'
                                                      for c in reversed(source)]
        for i in range(w):
            target[i].event(clocks[i],target_data[i]);guard[i].event(gc,guard_data[i])
        lines.append(observe(label+'_pre'))
        if owner=='target':
            for i in enabled:
                clocks[i]=active;target[i].event(clocks[i],target_data[i])
        else:
            gc=active
            for i in range(w):
                guard[i].event(gc,guard_data[i])
        lines.append(observe(label+'_capture'))
        clocks,gc=[idle]*w,idle
        for i in range(w):
            target[i].event(clocks[i],target_data[i]);guard[i].event(gc,guard_data[i])
        lines.append(observe(label+'_return'))
    return '\n'.join(lines)+'\n'


class GeneratedUdpState(unittest.TestCase):
    def test_all_864_rows_match_independent_transition_tables_and_instances(self):
        self.assertEqual(len(cases.MODEL.rows()),864)
        for row in cases.MODEL.rows():
            self.assertEqual(cases.reference(row),interpret(row),row)

    def test_selection_retains_all_pairs_triples_and_six_mandatory_cases(self):
        selected=cases.MODEL.select();self.assertEqual(len(selected),36)
        targets={t for row in selected for t in cases.MODEL.targets(row)}
        self.assertEqual(targets,cases.MODEL.universe())
        self.assertEqual(sum(len(t)==2 for t in targets),165)
        self.assertEqual(sum(len(t)==3 for t in targets),68)
        self.assertTrue(set(cases.MODEL.anchors)<=set(selected))

    def test_data_events_hold_and_unlisted_unknown_capture_becomes_x(self):
        for active in ('0','1'):
            idle=str(1-int(active));cell=Instance(1,idle,'0',active)
            cell.event(idle,'z');self.assertEqual(cell.state,'1')
            cell.event(active,'z');self.assertEqual(cell.state,'x')
            cell.event(idle,'0');self.assertEqual(cell.state,'x')
            cell.event(active,'0');self.assertEqual(cell.state,'0')

    def test_every_unknown_capture_is_primed_and_both_masks_cover_all_bits(self):
        row=cases.MODEL.anchors[1];w=int(row[0]);all_bits=set(range(w))
        plan=list(frames(row));self.assertEqual(len(plan),44)
        for p in range(3):
            first=next(i for i,a in enumerate(plan) if a[0]==f'u{p}_0')
            self.assertEqual([a[0] for a in plan[first-2:first]],[f'prime{p}_0',f'prime{p}_1'])
            self.assertTrue(all(a[1]=='1'*w for a in plan[first-2:first]))
            self.assertEqual(plan[first][3]|plan[first+1][3],all_bits)
            self.assertFalse(plan[first][3]&plan[first+1][3])

    def test_target_and_guard_have_258_distinct_captured_bit_histories(self):
        row=('129','logic','known','rise','0','if','masked');trace=interpret(row).splitlines()
        samples=[re.search(r' q=([01xz]+) guard=([01xz]+)',line).groups() for line in trace
                 if re.match(r'k\d+_1_capture ',line)]
        guard=[re.search(r' guard=([01xz]+)',line).group(1) for line in trace
               if re.match(r'guard\d+_capture ',line)]
        histories=list(zip(*(q for q,g in samples)))+list(zip(*guard))
        self.assertEqual(len(histories),258);self.assertEqual(len(set(histories)),258)
        self.assertEqual(guard[-2],'1'*129);self.assertEqual(guard[-1],'0'*129)

    def test_initial_categories_and_held_guard_remain_per_instance_until_guard_clock(self):
        row=cases.MODEL.anchors[1];text=interpret(row);initial=text.splitlines()[0]
        initial_guard=re.search(r'guard=([01xz]+)',initial).group(1)
        for line in text.splitlines():
            if re.match(r'(k|prime|u|recover)\d*_',line):
                self.assertTrue(line.endswith('guard='+initial_guard))
        for line in text.splitlines():
            if line.startswith('guard'):
                self.assertIn(' q='+'1'*129+' guard=',line)

    def test_bit_and_logic_conversion_precede_udp_z_normalization(self):
        row=('1','bit','z','rise','0','if','shared')
        self.assertIn('u0_0_capture raw=z source=0 clock=1 guard_clk=0 q=0 guard=1',interpret(row))
        self.assertIn('u0_0_capture raw=z source=z clock=1 guard_clk=0 q=x guard=1',
                      interpret((row[0],'logic',*row[2:])))

    def test_if_case_generate_forms_have_equal_observable_behavior(self):
        for row in cases.MODEL.anchors:
            equivalent=(*row[:5],'case' if row[5]=='if' else 'if',row[6])
            self.assertEqual(cases.reference(row),interpret(equivalent))

    def test_sources_render_and_fourstate_flags_follow_every_initial_and_capture(self):
        import common
        for row in cases.MODEL.select():
            case=cases.make_case(row);common.render(case,cases.NAME,cases.VERSION,cases.CHAPTER,'spec')
            words=re.findall(r'(?:raw|source|clock|guard_clk|q|guard)=([01xz]+)',case.expected)
            self.assertEqual(case.fourstate,any('x' in word or 'z' in word for word in words))
            self.assertEqual(len(case.expected.splitlines()),134 if row[2]!='known' else 98)
            self.assertNotIn('%v',case.body)
            self.assertIn('guard_data = ~source',case.body)


if __name__=='__main__':
    unittest.main()
