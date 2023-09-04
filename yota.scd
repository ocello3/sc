// https://yota.tehis.net/supako/

(
SynthDef("hat", { | amp = 0.1, pan = 0 |
	var sig, env;
	env = EnvGen.kr(Env.perc(0, 0.03), doneAction: 2);
	sig = WhiteNoise.ar;
	sig = sig * amp * amp;
	sig = Pan2.ar(sig, pan);
	Out.ar(0, sig);
}).add;

SynthDef(\snr, { | amp = 0.1, pan = 0 |
	var sig, env, snr, mem;
	env = EnvGen.kr(Env.perc(0, 0.05), 1, amp, doneAction: 2);
	snr = WhiteNoise.ar;
	mem = FSinOsc.ar(200);
	sig = LPF.ar(snr + mem, 12000);
	sig = Pan2.ar(sig, pan, env);
	Out.ar(0, sig);
}).add;

SynthDef(\kik, { | amp = 0.3, sustain = 1, freq = 30|
	var sig, frqEnv, ampEnv;
	frqEnv = EnvGen.kr(Env.perc, 1, freq * 10, freq, 0.023);
	ampEnv = EnvGen.kr(Env.linen(0.01, 0.1, 0.3, 1, [-5, 1, -4]), 1, amp, 0, sustain, 2);
	sig = SinOsc.ar(frqEnv, 0, ampEnv);
	sig = Pan2.ar(sig, 0);
	Out.ar(0, sig);
}).add;

SynthDef(\prc, { | out=0, amp=0.1 |
	var sig, env;
	env = EnvGen.kr(Env.perc(0, 0.08), 1, amp, doneAction: 2);
	sig = WhiteNoise.ar;
	sig = sig * env;
	Out.ar(out, sig);
}).add;

SynthDef(\bss, { | gate = 1, amp = 0.1, sustain = 1, freq = 440 |
	var sig, env;
	env = EnvGen.kr(Env.adsr, gate, amp, 0, sustain, 2);
	// add distrotion
	sig = Mix(Saw.ar([freq, freq + 0.1])).tanh;
	sig = RLPF.ar(sig, 1000, 0.8);
	sig = Pan2.ar(sig, 0, env);
	Out.ar(0, sig);
}).add;

SynthDef(\arp, { | gate=1, amp=0.1, sustain=1, freq=440, pan=0 |
	var sig, env;
	env = EnvGen.kr(Env.adsr, gate, amp, 0, sustain, 2);
	sig = Mix(LFSaw.ar([freq, freq + 0.1])).softclip;
	sig = RLPF.ar(sig, 4500, 0.5);
	sig = Pan2.ar(sig, pan, env);
	Out.ar(0, sig);
}).add;

SynthDef(\hrm, { | amp, freq=440 |
	var sig, env;
	env = EnvGen.kr(Env.perc, 1, amp, doneAction: 2);
	sig = Saw.ar([freq, freq*0.09]);
	sig = RLPF.ar(sig, 3200);
	Out.ar(0, sig * env);
}).add;

SynthDef(\lead, { | out=0, gate=1, amp=0.1, freq=440 |
	var sig, env;
	env = EnvGen.kr(Env.adsr(0.01), gate, amp, 0, 1, 2);
	sig = Mix.ar(LFTri.ar([freq, freq*2]));
	sig = HPF.ar(sig, 500);
	sig = sig * env;
	Out.ar(out, sig);
}).add;

SynthDef(\chorus, { | out = 0 |
	var sig;
	// get mono input signal
	sig = In.ar(out, 1) * 0.5;
	sig = DelayC.ar(sig, 1, FSinOsc.kr(0.25, [0, pi]).range(0.02, 0.03), 0.5, sig);
	// overwrite original signal
	ReplaceOut.ar(out, sig);
}).add;

SynthDef(\reverb, { | gate=1, out=0 |
	var sig, rev, env;
	env = Linen.kr(gate, 0.05, 1, 0.01, 2);
	sig = In.ar(out, 1) * 0.5;
	rev = BPF.ar(sig, 1000);
	4.do{ rev = AllpassN.ar(rev, 0.050, [0.050.rand, 0.050.rand], 1)};
	sig = sig + rev;
	sig = sig * env;
	ReplaceOut.ar(out, sig);
}).add;
)

Synth(\hat, [amp: 0.2, pan: 0]);
Synth(\snr, [amp: 0.2]);
Synth(\kik);
Synth(\prc);

(
TempoClock.default.tempo = 146/60;
~hatA = Pbind(
	\instrument, \hat,
	\dur, Pn(0.25, 4 * 4 * 8),
	\amp, Pseq([0.4, 0.2, 0.3, 0.2], inf),
	\pan, -0.5
).play;
~snrA = Pbind(
	\instrument, \snr,
	\dur, Pseq([
		Pseq([1, 1, 1, 1], 7),
		Pseq([1, 1, 0.5, Pn(0.25, 4), 0.5], 1)
	], 1),
	\degree, Pseq([
		Pseq([\, 1, \, 1], 7),
		Pseq([\, 1, \, Pn(1, 4), 1], 1)
	], 1)
).play;
~kikA = Pbind(
	\instrument, \kik,
	\dur, Pn(1, 4 * 8),
	\amp, 0.8,
	\freq, 50
).play;
~bssA = Pbind(
	\instrument, \bss,
	\dur, Pseq([
		Pseq([1.5, 1.5, 1.5, 1.5, 1, 1, 2, 0.5, 1, 2.5, 1, 1], 1),
		Pseq([1.5, 1.5, 1.5, 1, 1, 2, 2, 2, 1, 1], 1),
	], 1),
	\legato, 0.7,
	\amp, 0.6,
	\sale, [2, 4, 5, 7, 9, 10, 12],
	\degree, Pseq([
		Pseq([0, 1, 2, 0, 6, 2, 5, \, 4, 3, 5, 4], 1),
		Pseq([0, 1, 2, 0, 6, 2, 5, 5, 5, 4], 1)
	], inf),
	\octave, Pseq([
		Pseq([3, 3, 3, 3, 2, 3, 2, 2, 2, 2, 2, 2], 1),
		Pseq([3, 3, 3, 3, 2, 3, 2, 2, 2, 2, 2], 1)
	], inf)
).play;
/*
~prcA = Pfxb(
	Pbind(
	\instrument, \prc,
	\dur, Pseq([0.5, 0.25, 0.25], inf),
	\amp, Pseq([0.3, 0.13, 0.13], inf)
	),
	\chorus
).play;
*/
~arpA = Pbind(
	\instrument, \arp,
	\dur, Pseq([Pn(0.25, 4 * 14), 1, 1], 2),
	\legato, 0.5,
	\amp, 0.45,
	\scale, [2, 4, 5, 7, 9, 10, 12],
	\degree, Pseq([
		Pseq([0, 0, 0, 0, 0, 7, 4, 0], 7),
		-2, 3
	], inf),
	\octave, 3,
	\mtranspose, Pseq([Pn(0, 4 * 8), Pn(-2, 4 * 4), Pn(-4, 4 * 2), 0, 0], inf),
	\pan, Pseq([
		Pser([-1, 1], 4 * 14),
		0, 0
	], inf)
).play;
~harmA = Pbind(
	\instrument, \hrm,
	\dur, Pseq([
		Pseq([1.5, 1.5, 1.5, 1.5, 1, 1, 2, 0.5, 1, 2.5, 1, 1], 1),
		Pseq([1.5, 1.5, 1.5, 1.5, 1, 1, 2, 2, 2, 1, 1], 1)
	], 1),
	\legato, 1,
	\scale, [2, 4, 5, 7, 9, 10, 12],
	\degree, Pseq([
		Pseq([[2,0,-3], [3,0,-3], [4,0,-3], [2,0,-3], [1,-1,-3], [4,1,-1],
			[2,0,-3,-2], \, [1,-1,-4,-3], [0,-2,-5,-4], [0,-2,-5], [1,-0.9,-4]], 1),
		Pseq([[2,0,-3], [3,0,-3], [4,0,-3], [2,0,-3], [1,-1,-3], [4,1,-1],
			[2,0,-2], [4,2,0,-1], [7,5,4,2], [9,7,6,4], [8,6,4,3]], 1)
	], inf),
	\amp, 0.2,
).play;
~leadA = Pfxb(
	Pbind(
		\instrument, \lead,
		\dur, Pseq([4, Pn(0.5, 5), 0.25, 0.25, 0.5, 0.5, 6, 1, 1, 4, Pn(0.5, 5), 0.25, 0.25, 0.5, 0.5, 6, 1, 1], 1),
		\legato, 1.1,
		\amp, 0.3,
		\scale, [2, 4, 5, 7, 9, 10, 12],
		\degree, Pseq([2, \, 2, 3, 2, 1, 1, 0, -1, -3, 0, 0, 1, 2, \, 2, 3, 2, 1, 1, 0, -1, 0, 4, \, \], inf),
		\octave, 6
	),
	\reverb
).play;
)
Ppar([~hatA, ~snrA, ~kikA, ~prcA, ~bssA]).play;



~hatA.play;
~hatA.stop;
~snrA.stop;
~kikA.stop;
~prcA.stop;

p = Pseries(0, 2, 5).asStream; // 5 element array, start from 0, inc by 2
p = Pseq([6, 5, 1, 2.5, -100], inf).asStream;
p = Pgeom(start: 1, grow: 3, length: inf).asStream;
p = Pser([1, 2, 3], inf).asStream;
p = Prand([1, 2, 3, 4, 5], inf).asStream;
p = Pxrand([1, 2, 3, 4, 5], inf).asStream;
p = Pwrand([1, 2, 3, 4, 5], [1, 4, 8].normalizeSum, inf).asStream;
p = Pshuf([1, 2, 3], 3).asStream;

10.do { p.next.postln; };
p.next;