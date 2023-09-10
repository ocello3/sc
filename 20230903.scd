(
SynthDef(\hat, { | amp = 0.1, pan = 0.7, attack = 0, release = 0.05 |
	var sig, env;
	env = EnvGen.kr(Env.perc(attack, release), amp, doneAction: 2);
	sig = WhiteNoise.ar;
	sig = Pan2.ar(sig, pan, env);
	Out.ar(0, sig);
}).add;

SynthDef(\snr, { | amp = 0.1, pan = -0.7 |
	var sig, env, snr, mem;
	env = EnvGen.kr(Env.perc(0, 0.05), 1, amp, doneAction: 2);
	snr = WhiteNoise.ar;
	mem = FSinOsc.ar(200);
	sig = LPF.ar(snr + mem, 12000);
	sig = Pan2.ar(sig, pan, env);
	Out.ar(0, sig);
}).add;

SynthDef(\kik, { | amp = 0.3, sustain = 1, freq = 30, pan=0 |
	var sig, frqEnv, ampEnv;
	frqEnv = EnvGen.kr(Env.perc, 1, freq * 10, freq, 0.023);
	ampEnv = EnvGen.kr(Env.linen(0.01, 0.1, 0.3, 1, [-5, 1, -4]), 1, amp, 0, sustain, 2);
	sig = SinOsc.ar(frqEnv, 0, ampEnv);
	sig = Pan2.ar(sig, pan);
	Out.ar(0, sig);
}).add;
)

Synth(\hat, [amp: 0.8, pan: 0, attack: 0.1, release: 1]);
Synth(\snr, [amp: 0.2]);
Synth(\kik);

TempoClock.default.tempo = 72/60;
(
~hatA = Pbind(
	\instrument, \hat,
	\dur, Prand([0.5, 0.1, 0.1, 0.2, 0.4], inf),
	\amp, Pseq([0.4, 0.1, 0.2], inf),
	\pan, Prand([-0.8, 0, 0.8], inf),
	\attack, Prand([0, 0.04, 0.08, 0.1], inf),
	\release, Prand([0, 0.02, 0.04, 0.06, 0.08, 0.1], inf)
).play;
~snrA = Pbind(
	\instrument, \snr,
	\dur, Pseq([0.52, 0.48, 0.48, 1.02], inf),
	\amp, Pseq([0.3, 0.1, 0.5, 0.1], inf),
	\pan, 0.2,
).play;
~kikA = Pbind(
	\instrument, \kik,
	\dur, Pseq([0.95, 0.05, 1.95, 0.05], inf),
	\amp, Pseq([0.3, \], inf),
	\freq, 50
).play;
)