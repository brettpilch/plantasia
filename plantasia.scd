(
SynthDef(\squarepiano, {
	arg freq=440, pw=0.5, detune=2.0,
	sus=0.9, attack=0.01, decay=0.1, sustain=0.2, rq=1.0,
	cfstart=0.5, cfpeak=4.0, cfsus=2.0, cfend=0.5, fatk=0.01, fdec=0.1, flegato=1.0, frel=0.2,
	kt=1.0, fxout=0, fxamp=0.0,
	amp=0.2, out=0, pan=0.0;
	var sig, env, fenv;
	sig = LFPulse.ar([freq, freq + detune], 0, width: pw);
	fenv = EnvGen.kr(Env(
		[cfstart.pow(kt) * freq, cfpeak.pow(kt) * freq, cfsus.pow(kt) * freq, cfend.pow(kt) * freq],
		[fatk,fdec,flegato * sustain]
	));
	sig = BLowPass4.ar(sig, fenv, rq);
	env = EnvGen.kr(Env([0,1,sus,0], [attack, decay, sustain]), doneAction:2);
	sig = sig * env * amp;
	sig = Balance2.ar(sig[0], sig[1], pan);
	Out.ar(out, sig);
	Out.ar(fxout, sig * fxamp);
}).add;

SynthDef(\theremin, {
	arg freq=440, detune=2.0, t_trig=1.0, freqlag=0.5,
	vibrate=6.0, vibamt=10.0, pan=0.0,
	atk=0.01, sustain=0.2, amp=0.2, out=0,
	fxout=0, fxamp=0.0;
	var sig, env, freqmod;
	freq = Lag.kr(freq, freqlag);
	freqmod = SinOsc.kr(vibrate, 0, vibamt, [freq, freq + detune]);
	sig = SinOsc.ar([freqmod[0], freqmod[1]]);
	env = EnvGen.kr(Env.perc(atk, sustain), t_trig, doneAction:2);
	// env = EnvGen.kr(Env.adsr(atk, dec, sus, rel), gate, doneAction: 2);
	sig = sig * env * amp;
	sig = Balance2.ar(sig[0], sig[1], pan);
	Out.ar(out, sig);
	Out.ar(fxout, sig * fxamp);
}).add;

SynthDef(\theremin2, {
	arg freq=440, detune=2.0, t_trig=1.0, freqlag=0.5,
	vibrate=6.0, vibamt=10.0, pan=0.0,
	atk=0.01, sustain=0.2, amp=0.2, out=0,
	cf=2.0, rq=1.0,
	fxout=0, fxamp=0.0;
	var sig, env, freqmod;
	freq = Lag.kr(freq, freqlag);
	freqmod = SinOsc.kr(vibrate, 0, vibamt, [freq, freq + detune]);
	sig = LFSaw.ar([freqmod[0], freqmod[1]]);
	sig = BLowPass4.ar(sig, cf * freq, rq);
	env = EnvGen.kr(Env.perc(atk, sustain), t_trig, doneAction:2);
	// env = EnvGen.kr(Env.adsr(atk, dec, sus, rel), gate, doneAction: 2);
	sig = sig * env * amp;
	sig = Balance2.ar(sig[0], sig[1], pan);
	Out.ar(out, sig);
	Out.ar(fxout, sig * fxamp);
}).add;

SynthDef(\trumpet, {
	arg freq=440, detune=2.0, amp=0.2, out=0,
	atk=0.1, sustain=0.2, sus=0.2, rel=0.2, pan=0.0,
	cf=2.0, rq=1.0,
	fxout=0, fxamp=0.0;
	var sig, env;
	sig = LFSaw.ar([freq, freq + detune]);
	sig = BLowPass4.ar(sig, cf * freq, rq);
	env = EnvGen.kr(Env([0,1,sus,0], [atk, sustain, rel]), doneAction: 2);
	sig = sig * env * amp;
	sig = Balance2.ar(sig[0], sig[1], pan);
	Out.ar(out, sig);
	Out.ar(fxout, sig * fxamp);
}).add;

SynthDef(\bass, {
	arg freq=440, pw=0.5, pan=0.0, amp=0.2, out=0,
	sus=0.2, atk=0.01, sustain=0.2, rel=0.2,
	cfstart=0.5, cfpeak=4.0, cfsus=2.0, cfend=0.5,
	fatk=0.01, fdec=0.1, flegato=1.0, frel=0.2, kt=1.0, rq=1.0;
	var sig, env, fenv;
	sig = LFPulse.ar(freq, width: pw);
	fenv = EnvGen.kr(Env(
		[cfstart.pow(kt) * freq, cfpeak.pow(kt) * freq, cfsus.pow(kt) * freq, cfend.pow(kt) * freq],
		[fatk,fdec,flegato * sustain]
	));
	sig = BLowPass4.ar(sig, fenv, rq);
	env = EnvGen.kr(Env([0,1,sus,0], [atk, sustain, rel]), doneAction: 2);
	sig = sig * env * amp;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

SynthDef(\delay, {
	arg in, out=0, delaytime=0.5, decaytime=1.0;
	var sig;
	sig = In.ar(in, 2);
	sig = CombN.ar(sig, delaytime, delaytime, decaytime);
	Out.ar(out, sig);
}).add;

SynthDef(\reverb, {
	arg in, out=0, room=0.5, damp=0.5;
	var sig;
	sig = In.ar(in, 2);
	sig = FreeVerb2.ar(sig[0], sig[1], 1.0, room, damp);
	Out.ar(out, sig);
}).add;
)

Synth(\squarepiano, [\cfstart, 2.0, \cfpeak, 6.0, \cfsus, 4.0, \cfend, 0.5, \kt, 2.0]);

Synth(\theremin, [\sustain, 1.5, \vibrate, 6.0, \vibamt, 25.0, \freq, 880, \detune, 0.0]);

Synth(\bass);

(
// time variables:
~tempo = 175.0; //bpm
~quarternote = 60 / ~tempo;
~eighthnote = ~quarternote / 2;
~sixteenthnote = ~eighthnote / 2;
~eighthtrip = ~eighthnote / 3 * 2;
~measure = 4 * ~eighthnote;
~twentyfourth = ~measure / 12.0;

// note sequences:
~intro = Pseq([56,63,68,63,72,68,63,60], 4);

~verse = Pseq([
	Pseq([56,63,68,63,72,68,63,60], 1),
	Pseq([54,63,66,63,70,66,63,58], 1),
	Pseq([53,60,65,60,68,65,Rest,60], 1),
	Pseq([52,61,64,61,68,64,61,58], 1),
	Pseq([51,60,63,60,68,63,60,56], 1),
	Pseq([50,62,65,62,68,65,62,56], 1),
	Pseq([49,56,61,58,65,61,58,53], 1),
	Pseq([48,55,60,58,64,60,58,55], 1),
	Pseq([53,60,65,60,68,65,60,56], 1),
	Pseq([51,60,63,60,66,63,60,54], 1),
	Pseq([49,53,61,56,65,61,56,48], 1),
	Pseq([46,53,58,61,44,53,58,61], 1),
	Pseq([43,53,61,58,65,61,58,53], 1),
	Pseq([43,61,65,61,70,65,61,58], 1),
	Pseq([48,58,60,58,65,60,58,60], 1),
	Pseq([48,55,60,58,64,60,58,60], 1),
	Pseq([53,60,65,60,69,65,60,57], 1),
	Pseq([51,60,63,60,67,63,60,55], 1),
	Pseq([50,58,62,58,65,62,58,53], 1),
	Pseq([49,56,61,58,65,61,58,53], 1),
	Pseq([48,57,60,57,65,60,57,53], 1),
	Pseq([47,53,62,57,65,62,57,53], 1), // 27
	Pseq([46,58,62,58,67,62,58,55], 1),
	Pseq([45,57,64,61,67,64,61,57], 1),
	Pseq([50,53,62,57,65,62,57,53], 1),
	Pseq([48,53,63,57,65,63,57,53], 1),
	Pseq([46,53,62,58,65,62,65,62], 1),
	Pseq([70,65,74,70,65,62,58,53], 1),
	Pseq([52,58,62,58,67,62,70,67], 1),
	Pseq([74,67,70,67,58,55,50,55], 1),
	Pseq([51,55,61,58,63,61,67,63], 1),
	Pseq([70,67,75,73,70,67,63,61], 1),
], 1);

~verse3 = Pseq([
	Pseq([56,63,68,63,72,68,63,60], 1),
	Pseq([54,63,66,63,70,66,63,58], 1),
	Pseq([53,60,65,60,68,65,Rest,60], 1),
	Pseq([52,61,64,61,68,64,61,58], 1),
	Pseq([51,60,63,60,68,63,60,56], 1),
	Pseq([50,62,65,62,68,65,62,56], 1),
	Pseq([49,56,61,58,65,61,58,53], 1),
	Pseq([48,55,60,58,64,60,58,55], 1),
	Pseq([53,60,65,60,68,65,60,56], 1),
	Pseq([51,60,63,60,66,63,60,54], 1),
	Pseq([49,53,61,56,65,61,56,48], 1),
	Pseq([50,53,62,56,65,62,56,53], 1),
	Pseq([51,56,63,60,68,63,60,56], 1),
	Pseq([51,56,65,61,70,63,67,58], 1),
], 1);

~chorus = Pseq([
	Pseq([80,75,72,68,72,75], 2),
	Pseq([79,75,72,67,72,75], 2),
	Pseq([78,73,70,66,70,73], 2),
	Pseq([77,73,70,65,70,73], 2),
	Pseq([76,71,68,64,68,71], 2),
	Pseq([75,71,68,63,68,71], 2),
	Pseq([73,68,66,61,66,68], 2),
	Pseq([73,68,65,61,65,68], 2),
	Pseq([78,73,70,66,70,73], 2),
	Pseq([77,73,70,65,70,73], 2),
	Pseq([76,71,68,64,68,71], 2),
	Pseq([75,71,68,63,68,71], 2),
	Pseq([74,69,66,62,66,69], 2),
	Pseq([73,69,66,61,66,69], 2),
	Pseq([71,66,63,59,63,66], 2),
	Pseq([75,71,66,63,66,71], 2),
	Pseq([73,68,65,61,65,68], 2),
	Pseq([77,73,68,65,68,73], 2),
	Pseq([75,70,67,63,67,70], 2),
	Pseq([79,75,70,67,70,75], 2),
	Pseq([82,79,75,70,75,79], 2),
	Pseq([87,84,82,79,75,73,70,67,63,61,58,55], 1),
], 1);

~chorus2 = Pseq([
	Pseq([80,75,72,68,72,75], 2),
	Pseq([79,75,72,67,72,75], 2),
	Pseq([78,73,70,66,70,73], 2),
	Pseq([77,73,70,65,70,73], 2),
	Pseq([76,71,68,64,68,71], 2),
	Pseq([75,71,68,63,68,71], 2),
	Pseq([73,68,66,61,66,68], 2),
	Pseq([73,68,65,61,65,68], 2),
	Pseq([78,73,70,66,70,73], 2),
	Pseq([77,73,70,65,70,73], 2),
	Pseq([76,71,68,64,68,71], 2),
	Pseq([75,71,68,63,68,71], 2),
	Pseq([74,69,66,62,66,69], 2),
	Pseq([73,69,66,61,66,69], 2),
	Pseq([71,66,63,59,63,66], 2),
	Pseq([75,71,66,63,66,71], 2),
	Pseq([73,68,65,61,65,68], 2),
	Pseq([77,73,68,65,68,73], 2),
	Pseq([75,70,67,63,67,70], 2),
	Pseq([79,75,70,67,70,75], 2),
	Pseq([82,79,75,70,75,79], 2),
	Pseq([87,82,79,75,79,82], 2),
], 1);

~chorus3 = Pseq([
	Pseq([80,75,72,68,72,75], 2),
	Pseq([79,75,72,68,72,75], 2),
	Pseq([78,73,70,66,70,73], 2),
	Pseq([77,73,70,65,70,73], 2),
	Pseq([76,71,68,64,68,71], 2),
	Pseq([75,71,68,63,68,71], 2),
	Pseq([73,68,66,61,66,68], 2),
	Pseq([73,68,65,61,65,68], 2),
	Pseq([75,70,67,63,67,70], 2),
	Pseq([75,70,67,63,67,70], 2),
	Pseq([77,72,69,65,69,72], 2),
	Pseq([77,72,69,65,69,72], 2),
	Pseq([77,72,69,65,69,72], 2),
	Pseq([81,77,72,65,72,77], 2),
	Pseq([84,81,77,72,77,81], 2),
	Pseq([89,84,81,77,81,84], 2),
	Pseq([89], 1),
], 1);

~thereminversenotes = Pseq([
	87,87,92,89,85,84,82,84,89,82,84,82,80,84,80,
	77,79,80,82,82,84,82,81,79,81,77,79,81,81,
	79,81,77,76,77,75,77,74,70,72,74,74,79,82,
	86,85,87,85,82,79,
]);

~thereminversedurs = Pseq([
	4,2,2,2,4,1,1,6,2,6,1,1,6,2,2,
	2,2,2,8,2,4,2,4,3,1,7,1,4,2,
	1,1,4,4,4,3,1,2,2,2,2,2,2,2,
	2,4,1,1,1,1,
]);

~thereminverse2notes = Pseq([
	87,92,89,85,84,82,84,89,82,84,82,80,84,80,
	77,79,80,82,82,84,82,81,79,81,77,79,81,81,
	79,81,77,76,77,75,77,74,70,72,74,79,74,82,
	79,86,82,79,85,82,87,85,82,79,75,
]);

~thereminverse2durs = Pseq([
	6,2,2,4,1,1,6,2,6,1,1,6,2,2,
	2,2,2,8,2,4,2,4,3,1,7,1,4,2,
	1,1,4,4,4,3,1,2,2,2,2,1,1,1,
	1,2,1,1,1,1,1,1,1,1,4,
]);

~thereminverse3notes = Pseq([
	87,92,89,85,84,82,84,89,82,84,80,84,87,92,
	89,91,92,92,94,91,92,91,87,89,90,89,85,87,
	88,87,83,80,85,Rest,87,Rest,89,
]);

~thereminverse3durs = Pseq([
	6,2,2,4,1,1,6,2,6,2,6,1,1,2,
	2,2,2,6,1,1,4,2,1,1,4,2,1,1,
	4,2,1,1,8,8,8,8,8,
]);

~bassversenotes = Pseq([
	Rest,
	48,53,53,51,51,50,50,49,49,48,48,47,47,46,
	46,45,47,48,50,50,48,48,46,46,55,53,52,64,
	52,52,51,Rest,
]);

~bassversedurs = Pseq([
	158,
	2,6,2,6,2,6,2,6,2,6,2,6,2,6,
	2,4,2,2,6,2,6,2,6,2,4,4,6,2,
	6,2,4,11,
]);

~bassverse2notes = Pseq([
	68,68,66,66,65,65,64,64,63,63,62,62,61,
	61,60,62,64,65,65,63,63,61,60,58,56,55,
	67,55,67,55,48,55,53,55,62,64,65,65,63,
	63,62,50,62,61,49,61,60,48,60,59,47,59,
	58,46,58,57,59,60,62,50,62,60,48,60,58,
	57,55,53,52,64,52,64,52,51,Rest,
]);

~bassverse2durs = Pseq([
	6,2,6,2,6,2,6,2,6,2,6,2,6,
	2,4,2,2,6,2,6,2,6,2,4,4,2,
	4,2,6,2,2,4,2,4,2,2,6,2,6,
	2,2,4,2,2,4,2,2,4,2,2,4,2,
	2,4,2,4,2,2,2,4,2,2,4,2,6,
	2,4,4,2,4,2,6,2,4,11,
]);

~bassverse3notes = Pseq([
	56,68,56,54,66,54,53,65,53,52,64,52,51,
	63,51,50,62,50,49,61,49,48,60,62,64,65,
	53,51,63,51,49,61,49,50,62,50,51,63,51,
	51,Rest,
]);

~bassverse3durs = Pseq([
	2,4,2,2,4,2,2,4,2,2,4,2,2,
	4,2,2,4,2,2,4,2,2,2,2,2,6,
	2,2,4,2,2,4,2,2,4,2,2,4,2,
	6,2,
]);

~basschorusnotes = Pseq([
	51,56,51,56,56,48,55,60,55,54,61,54,61,
	58,65,58,58,52,59,52,59,56,63,56,56,49,
	56,61,56,61,56,61,61,56,54,61,54,61,58,
	65,58,58,52,59,52,59,56,63,56,63,50,57,
	62,57,54,61,54,61,59,54,59,54,59,54,59,
	54,59,54,61,56,61,56,61,56,61,56,61,56,
	51,58,63,58,51,58,63,58,63,58,63,
]);

~basschorusdurs = Pseq([
	1,3,1,3,1,3,1,3,1,3,1,3,1,
	3,1,3,1,3,1,3,1,3,1,3,1,3,
	1,3,1,3,1,2,1,1,3,1,3,1,3,
	1,3,1,3,1,3,1,3,1,3,1,3,1,
	3,1,3,1,3,1,3,1,3,1,3,1,1,
	1,1,1,3,1,3,1,3,1,1,1,1,1,
	3,1,3,1,3,1,1,1,1,1,16,
]);

~basschorus3notes = Pseq([
	56,51,56,56,48,55,60,55,54,61,54,61,58,
	65,58,58,52,59,52,59,56,63,56,56,49,56,
	61,56,49,56,61,56,61,56,51,58,63,58,51,
	58,63,58,63,58,53,60,65,60,53,60,65,60,
	65,60,53,60,65,60,53,60,65,60,65,60,[65, 53],
]);

~basschorus3durs = Pseq([
	3,1,3,1,3,1,3,1,3,1,3,1,3,
	1,3,1,3,1,3,1,3,1,3,1,3,1,
	3,1,3,1,1,1,1,1,3,1,3,1,3,
	1,1,1,1,1,3,1,3,1,3,1,1,1,
	1,1,3,1,3,1,3,1,1,1,1,1,16,
]);

~fluteversenotes = Pseq([
	60,60,65,62,58,57,55,57,62,55,57,55,53,57,
	53,50,52,53,55,53,55,
]);

~fluteversedurs = Pseq([
	4,2,2,2,4,1,1,6,2,6,1,1,6,2,
	2,2,2,2,7,1,8,
]);

~fluteverse2notes = Pseq([
	56,54,53,52,51,50,49,48,50,52,53,51,49,46,
	44,43,Rest,
	60,60,65,62,58,57,55,57,62,55,57,55,53,57,
	53,50,52,53,55,53,55,56,58,60,
]);

~fluteverse2durs = Pseq([
	4,4,4,4,4,4,4,2,1,1,4,4,4,2,
	2,8,8,
	4,2,2,2,4,1,1,6,2,6,1,1,6,2,
	2,2,2,2,7,1,4,2,2,2,
]);

~fluteverse3notes = Pseq([
	56,54,53,52,51,50,49,48,50,52,53,51,49,50,51,Rest,60
]);

~fluteverse3durs = Pseq([
	4,4,4,4,4,4,4,2,1,1,4,4,4,4,6,2,2,
]);

~trumpetchorusnotes = Pseq([
	68,67,63,65,66,65,61,63,64,63,59,56,61,63,
	65,66,65,61,63,64,63,59,61,62,61,57,54,63,
	61,63,65,63,65,67,67,70,73,75,
]);

~trumpetchorusdurs = Pseq([
	4,2,1,1,4,2,1,1,4,2,1,1,6,1,
	1,4,2,1,1,4,2,1,1,4,2,1,1,6,
	1,1,6,1,1,3,1,3,1,7,
]) * 6;

~trumpetchorus2notes = Pseq([
	68,67,63,65,66,65,61,63,64,63,59,56,61,63,
	65,66,65,61,63,64,64,63,59,62,61,57,54,63,
	61,63,65,65,63,65,67,70,70,75,70,70,75,
]);

~trumpetchorus2durs = Pseq([
	Pseq([4,2,1,1,4,2,1,1,4,2,1,1,6,1,1,4,2,1,1,3,1,2,2,4,2,1,1]) * 6,
	40,4,4,36,4,4,4,12,9,3,36,9,3,18,
]);

~trumpetchorus3notes = Pseq([
	68,67,63,65,66,65,61,63,64,63,59,56,61,56,
	61,63,58,63,65,60,60,65,
]);

~trumpetchorus3durs = Pseq([
	4,2,1,1,4,2,1,1,4,2,1,1,6,1,
	1,6,1,1,6,1,1,4,
]) * 6;

~brassnotes = Pseq([
	Pseq([Rest], 4 * 4), // intro
	Pseq([
		Pseq([Rest], 32 * 4), // verse
		[63,72,68], Pseq([Rest], 3),
		[60,63,67], Pseq([Rest], 3),
		[70,61,66], Pseq([Rest], 3),
		[58,61,65], Pseq([Rest], 3),
		[59,68,64], Pseq([Rest], 3),
		[63,56,59], Pseq([Rest], 3),
		[68,61,65], Pseq([Rest], 3),
		[65,61,68], Pseq([Rest], 3),
		[70,61,66], Pseq([Rest], 3),
		[58,61,65], Pseq([Rest], 3),
		[59,68,64], Pseq([Rest], 3),
		[63,56,59], Pseq([Rest], 3),
		[57,62,66], Pseq([Rest], 3),
		[54,57,61], Pseq([Rest], 3),
		[54,63,59], Pseq([Rest], 7),
		[68,61,65], Pseq([Rest], 5),
		[61,65], Rest,
		[70,63,67], Pseq([Rest], 15),
	], 2),
	Pseq([Rest], 14 * 4), // verse 3
	[63,72,68], Pseq([Rest], 3),
	[60,63,67], Pseq([Rest], 3),
	[70,61,66], Pseq([Rest], 3),
	[58,61,65], Pseq([Rest], 3),
	[59,68,64], Pseq([Rest], 3),
	[63,56,59], Pseq([Rest], 3),
	[68,61,65], Pseq([Rest], 3),
	[65,61,68], Pseq([Rest], 3),
	[58,63,67], Pseq([Rest], 7),
	[60,69,65], Pseq([Rest], 7),
	[60,69,65], Pseq([Rest], 7),
]);
)

(
~delaybus = Bus.audio(s, 2);
~reverbbus = Bus.audio(s, 2);
//Synth(\delay, [\in, ~delaybus, \delaytime, ~eighthnote, \decaytime, ~measure]);
//Synth(\reverb, [\in, ~reverbbus, \room, 0.5, \damp, 0.5]);

// main patterns:
~delay = Pmono(
	\delay,
	\in, ~delaybus,
	\delaytime, ~eighthnote,
	\decaytime, ~measure
);

~reverb = Pmono(
	\reverb,
	\in, ~reverbbus,
	\room, 0.5,
	\damp, 0.4
);

~arp = Pbind(
	\instrument, \squarepiano,
	\legato, 0.85,
	\midinote, Pseq([
		~intro,
		~verse,
		~chorus,
		~verse,
		~chorus2,
		~verse3,
		~chorus3,
	]) + 12,
	\dur, Pseq([
		Pseq([~eighthnote], 4 * 8), // intro
		Pseq([~eighthnote], 32 * 8), // verse 1
		Pseq([~eighthtrip], 22 * 12), // chorus 1
		Pseq([~eighthnote], 32 * 8), // verse 2
		Pseq([~eighthtrip], 22 * 12), // chorus 2
		Pseq([~eighthnote], 14 * 8), // verse 3
		Pseq([~eighthtrip], 16 * 12 + 1), // chorus 3
	]),
	\amp, 0.06,
	\cfstart, 2.0,
	\cfpeak, 4.0,
	\cfsus, 3.0,
	\cfend, 0.5,
	\detune, 2.0,
	\kt, 0.75,
	\pan, 0.9,
	\fxout, ~delaybus,
	\fxamp, 0.5
);

~lead = PmonoArtic(\theremin,
	\legato, Pseq([
		Pseq([4.0], 49),
		0.99,
		Pseq([4.0], 53),
		0.99,
		Pseq([4.0], 33),
		Pseq([0.99], 5),
	]),
	\midinote, Pseq([
		Rest, // intro
		~thereminversenotes,
		Rest, // chorus 1
		~thereminverse2notes,
		Rest, // chorus 2
		~thereminverse3notes,
		Rest
	]) + 12,
	\durnum, Pseq([
		15.97, // intro
		~thereminversedurs,
		88, // chorus 1
		~thereminverse2durs,
		86, // chorus 2
		~thereminverse3durs,
		4
	]),
	\dur, Pkey(\durnum) * ~quarternote,
	\amp, 0.034,
	\atk, 0.1,
	//\sustain, 24 * ~quarternote,
	\freqlag, 0.2,
	\vibrate, ~tempo / 60 * 2, // eighth note rhythm
	\vibamt, 60.0,
	\detune, 0.0,
	\pan, (-0.9),
	\fxout, ~reverbbus,
	\fxamp, 0.5
);

~lead2 = PmonoArtic(\theremin2,
	\midinote, Pseq([
		Rest,
		~fluteversenotes,
		Rest,
		~fluteverse2notes,
		Rest,
		~fluteverse3notes,
		Rest
	]),
	\durnum, Pseq([
		80, // intro
		~fluteversedurs,
		88, // chorus 1
		~fluteverse2durs,
		86, // chorus 2
		~fluteverse3durs,
		2,
	]),
	\legato, Pseq([
		Pseq([4.0], 21),
		0.99,
		Pseq([4.0], 16),
		0.99,
		Pseq([4.0], 24),
		0.99,
		Pseq([4.0], 15),
		0.99, 1.0, 0.99, 1.0
	]),
	\dur, Pkey(\durnum) * ~quarternote,
	\amp, 0.075,
	\atk, 0.9,
	//\sustain, 24 * ~quarternote,
	\freqlag, 0.0,
	\cf, 4.5,
	\rq, Pwhite(0.9, 0.99, inf),
	\vibrate, ~tempo / 60 * 2, // eighth note rhythm
	\vibamt, 2.0,
	\detune, 0.0,
	\pan, 0.7,
	\fxout, ~reverbbus,
	\fxamp, 0.5
);

~bass = Pbind(
	\instrument, \bass,
	\legato, 0.98,
	\midinote, Pseq([
		~bassversenotes,
		~basschorusnotes,
		~bassverse2notes,
		~basschorusnotes,
		~bassverse3notes,
		~basschorus3notes,
	]) - 12,
	\durnum, Pseq([
		~bassversedurs,
		~basschorusdurs,
		~bassverse2durs,
		~basschorusdurs,
		~bassverse3durs,
		~basschorus3durs,
	]),
	\dur, Pkey(\durnum) * ~eighthnote,
	\amp, 0.18,
	\atk, 0.02,
	\sus, 0.2,
	\cfstart, 0.8,
	\cfpeak, 4.0,
	\cfsus, 3.0,
	\cfend, 0.5,
	\pan, (-0.7),
);

~trumpet = Pbind(
	\instrument, \trumpet,
	\midinote, Pseq([
		Rest, // verse 1
		~trumpetchorusnotes,
		Rest, // verse 2
		~trumpetchorus2notes,
		Rest, // verse 3
		~trumpetchorus3notes,
	]),
	\durnum, Pseq([
		144 * 6, // verse 1
		~trumpetchorusdurs,
		129 * 6, // verse 2
		~trumpetchorus2durs,
		57 * 6, // verse 3
		~trumpetchorus3durs,
	]),
	\dur, Pkey(\durnum) * ~twentyfourth,
	\amp, 0.17,
	\cf, 7.0,
	\rel, 0.1,
	\atk, 0.05,
	\sus, 0.1,
	\rq, 0.9,
	\fxout, ~reverbbus,
	\fxamp, 0.7
);

~brass = Pbind(
	\instrument, \trumpet,
	\midinote, ~brassnotes - 12,
	\dummy, 1,
	\legato, 2.0,
	\dur, ~quarternote,
	\amp, 0.1,
	\cf, 7.0,
	\rel, 0.2,
	\atk, 0.1,
	\rq, 0.9,
	\pan, Pseq([[-0.9, 0.0, 0.9]], inf),
	\fxout, ~reverbbus,
	\fxamp, 0.5
);

Ppar([
	~delay,
	~reverb,
	~arp,
	~lead,
	~lead2,
	~bass,
	~trumpet,
	~brass
]).play(quant: ~measure); //.record("/Users/brettpilch/Desktop/recordings/plantasia.wav", "WAV");
)

// .play(quant: ~measure); //

s.quit;