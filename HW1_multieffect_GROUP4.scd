s.boot

(
var sig, sigF, sigW, sigP, sig1;
var outF, outW, outP;
var lfoW, lfoP;
var freqW, freqP;
var feedback, freqBand;
var freq, bw, freq2, cFreq, cFreqP;
var x, mod1, delay;
var cutoff, resonance;
var freqKnob, bwKnob,feedbackKnob, cFreqKnob, panSlider, freqKnob2, bypass1, bypass2, bypass3;
var mixKnob, mixKnob2, mixKnob3, mix, mix2, mix3;
var moveBefore1, moveAfter1, moveBefore2, moveAfter2, flanger, wahwah, phaser;
var be1, be2, af1;
var w1, w2, w3;
var fontTitle, fontKnob, fontButton, inputText, outputText;
var color1, colorF, colorW, colorP;
var slider, volume, mute;
var cSpec, scope, scope1;

b = Buffer.read(s,"Sample.wav");

~bufferIn = Buffer.alloc(s,1024,2);
~bufferOut = Buffer.alloc(s,1024,2);
~flangerActive = 1;
~wahActive = 1;
~phaserActive = 1;
~mixF = 0;
~mixW = 0;
~mixP = 0;


(
SynthDef("flange", {arg inBus, outBus, feedback = 0.1, mfreqF = 0.1, mixF = 0;
	sigF=In.ar(inBus, 2);
	outF = sigF + LocalIn.ar(2);
	outF= DelayN.ar(outF,0.02,SinOsc.kr(mfreqF,0,0.005,0.005));
	LocalOut.ar(feedback*outF);
	outF = Mix.ar([outF*mixF, sigF*(1-mixF)]);
	Out.ar(outBus, Pan2.ar(outF));
}).send(s);
);

(
SynthDef("wah",{
	arg mixW=0, cFreqW=0.5, bwW=0, inBus, outBus;
	sigW = In.ar(inBus, 2);
	freqBand = SinOsc.kr(cFreqW).range(0,1);
	//freqBand = 1 - cFreqW;
	outW = BBandPass.ar(sigW, 2100*freqBand+400, 3*bwW+0.05, mixW);
	outW =Mix.ar([outW*mixW, sigW*(1-mixW)]);
	Out.ar(outBus, Pan2.ar(outW));
}).send(s);
);

(
SynthDef("phaser", {arg inBus, outBus, mfreqP = 0.2, mixP = 0;
	sigP = In.ar(inBus, 2);
	outP= BAllPass.ar(sigP,0.02,SinOsc.kr(mfreqP,0,0.01,0.01));
	outP = Mix.ar([outP*mixP, sigP*(1-mixP)]);
	// Out.ar (outBus, outP);
	Out.ar(outBus, Pan2.ar(outP));
}).send(s);
);

(
~inBus = Bus.audio(s, 2);
~eff1Bus = Bus.audio(s, 2);
~eff2Bus = Bus.audio(s, 2);
~outBus = Bus.audio(s,2);
);

(
x = Synth.new(\flange, [\inBus, ~inBus, \outBus, ~eff1Bus]);
y = Synth.after(x, \wah, [\inBus, ~eff1Bus, \outBus, ~eff2Bus]);
z = Synth.after(y, \phaser,  [\inBus, ~eff2Bus, \outBus,  ~outBus]);
);

(
{
	var sig;
	sig = PlayBuf.ar(2, b, loop:1);
	sig = sig*0.5;
	ScopeOut2.ar(sig, ~bufferIn);
	Out.ar(~inBus, sig);
}.play;
);

(
{ arg inBus;
	sig1 = In.ar(inBus, 2);
	ScopeOut2.ar(sig1, ~bufferOut);
	Out.ar(0, sig1);
}.play(args:[\inBus, ~outBus], addAction:\addToTail);
);


GUI.current;

(

fontTitle = Font.new("Open Sans", 60, true);
fontKnob = Font.new("Open Sans", 15, true);
fontButton = Font.new("Open Sans", 15, true);


color1 = Color.fromHexString("#373854");
colorF = Color.fromHexString("#e86af0");
colorW = Color.fromHexString("#9e379f");
colorP = Color.fromHexString("#7bb3ff");


j = 1;
k = 2;
l = 3;


be1 = 2;
be2 = 3;
af1 = 1;

mute = 0;

a = Window.new(bounds: Rect(128, 90, 1350, 750), resizable: false).background_(color1);

w1 = CompositeView(a, Rect(10,10,420,410)).background_(colorF);

w2 = CompositeView(a, Rect(440,10,420,410)).background_(colorW);

w3 = CompositeView(a, Rect(870,10,420,410)).background_(colorP);

volume = s.volume;

scope = ScopeView(a, Rect(10,510,655,210));
scope.maxSize = Size(655,210);
scope.server = s;
scope.bufnum = ~bufferIn.bufnum;
scope.start;

scope1 = ScopeView(a, Rect(680,510,655,210));
scope1.maxSize = Size(655,210);
scope1.server = s;
scope1.bufnum = ~bufferOut.bufnum;
scope1.start;

scope.background_(color1).waveColors_(Color.white);
scope1.background_(color1).waveColors_(Color.white);

cSpec = ControlSpec(-90, 6, 'db');

slider = Slider(a, Rect(1300, 10, 40, 410));
slider.maxSize = Size(40, 410);
slider.action_({
 	volume.volume = cSpec.map(slider.value);
});
slider.background = colorW;
slider.value = cSpec.unmap(0);


feedbackKnob = Knob(a);
freqKnob = Knob(a);
mixKnob = Knob(a);

feedbackKnob.action_({ arg feedback;
	x.set(\feedback, feedback.value*0.9);
});
freqKnob.action_({ arg freq;
	x.set(\mfreqF, freq.value*0.02);
});
mixKnob.action_({ arg mix;
	if ( ~flangerActive == 1, {
		x.set(\mixF, mix.value);
	});
	~mixF = mix.value;
	x.get(\mixF, {arg value; value.postln;});
});

feedbackKnob.color = [color1, color1, colorF, colorF];
freqKnob.color = [color1, color1, colorF, colorF];
mixKnob.color = [color1, color1, colorF, colorF];


bwKnob = Knob(a);
cFreqKnob = Knob(a);
mixKnob2 = Knob(a);

bwKnob.action_({ arg freq;
	y.set(\bwW, freq.value);
});
cFreqKnob.action_({ arg cFreq;
	y.set(\cFreqW, cFreq.value*0.75);
});
mixKnob2.action_({ arg mix;
	if ( ~wahActive == 1, {
		y.set(\mixW, mix.value);
	});
	~mixW = mix.value;
});

cFreqKnob.color = [color1, color1, colorW, colorW];
bwKnob.color = [color1, color1, colorW, colorW];
mixKnob2.color = [color1, color1, colorW, colorW];


freqKnob2 = Knob(a);
mixKnob3 = Knob(a);

freqKnob2.action_({ arg freq;
	z.set(\mfreqP, freq.value);
});
mixKnob3.action_({ arg mix;
	if ( ~phaserActive == 1, {
		z.set(\mixP, mix.value);
	});
	~mixP = mix.value;
});

freqKnob2.color = [color1, color1, colorP, colorP];
mixKnob3.color = [color1, color1, colorP, colorP];

bypass1 = Button(a, Rect(10, 450, 420, 30)).font_(fontButton);
bypass1.maxSize = Size(420,30);
bypass1.states = [["BYPASS", color1, Color.cyan], ["BYPASSED", Color.cyan, color1]];
bypass1.action_({ arg butt;
	if (~flangerActive == 1, {
		x.set(\mixF, 0);
		~flangerActive = 0;
	}, {
		x.set(\mixF, ~mixF);
		~flangerActive = 1;
	}
	);
});

bypass2 = Button(a, Rect(440,450,420,30)).font_(fontButton);
bypass2.maxSize = Size(420,30);
bypass2.states = [["BYPASS", color1, Color.cyan], ["BYPASSED", Color.cyan, color1]];
bypass2.action_({ arg butt;
	if (~wahActive == 1, {
		y.set(\mixW, 0);
		~wahActive = 0;
	}, {
		y.set(\mixW, ~mixW);
		~wahActive = 1;
	}
	);
});

bypass3 = Button(a, Rect(870,450,420,30)).font_(fontButton);
bypass3.maxSize = Size(420,30);
bypass3.states = [["BYPASS", color1, Color.cyan], ["BYPASSED", Color.cyan, color1]];
bypass3.action_({ arg butt;
	if (~phaserActive == 1, {
		z.set(\mixP, 0);
		~phaserActive = 0;
	}, {
		z.set(\mixP, ~mixP);
		~phaserActive = 1;
	}
	);
});


r = Button(a);
r.states = [["MUTE", color1, Color.cyan], ["MUTED", Color.cyan, color1]];
r.maxSize = Size(35,35);
r.action_({ arg butt;
	if (mute == 0, {
		volume.mute;
		mute = 1;
	}, {
		volume.unmute;
		mute = 0;
	}
	);
});

flanger = StaticText().string_("FLANGER").font_(fontTitle).stringColor_(color1).align_(\center);
wahwah = StaticText().string_("WAH WAH").font_(fontTitle).stringColor_(color1).align_(\center);
phaser = StaticText().string_("PHASER").font_(fontTitle).stringColor_(color1).align_(\center);
feedback = StaticText().string_("feedback").font_(fontKnob).stringColor_(color1).align_(\center);
freq = StaticText().string_("freq").font_(fontKnob).stringColor_(color1).align_(\center);
cFreq = StaticText().string_("wah speed").font_(fontKnob).stringColor_(color1).align_(\center);
bw = StaticText().string_("bandwidth").font_(fontKnob).stringColor_(color1).align_(\center);
freq2 = StaticText().string_("freq").font_(fontKnob).stringColor_(color1).align_(\center);
mix = StaticText().string_("mix").font_(fontKnob).stringColor_(color1).align_(\center);
mix2 = StaticText().string_("mix").font_(fontKnob).stringColor_(color1).align_(\center);
mix3 = StaticText().string_("mix").font_(fontKnob).stringColor_(color1).align_(\center);
inputText = StaticText().string_("INPUT").font_(fontKnob).stringColor_(Color.white).align_(\center);
outputText = StaticText().string_("OUTPUT").font_(fontKnob).stringColor_(Color.white).align_(\center);

moveAfter1 = Button(a, Rect(10, 425, 420, 20)).font_(fontButton);
moveAfter1.states_([["MOVE AFTER", color1, Color.white]]);
moveAfter1.action_({
	switch(af1,
		1, {
			if(k == 2, {
				x.moveAfter(y);
				a.layout_(
					VLayout(
					VLayout(
						HLayout(
							VLayout([wahwah, align:\top], VLayout(mixKnob2, mix2), HLayout( VLayout(bwKnob, bw),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [flanger, align:\top], VLayout(mixKnob, mix), HLayout( VLayout(feedbackKnob, feedback),
								VLayout(freqKnob, freq))),
							VLayout( [phaser, align:\top], VLayout(mixKnob3, mix3), HLayout( VLayout(freqKnob2, freq2)
								)), slider
						), HLayout(VLayout(moveAfter1, bypass2),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass1),
							VLayout(moveBefore2, bypass3),r)
					), HLayout(scope, scope1), HLayout(inputText, outputText))
				).front;

				k = 1;
				j = 2;
				af1 = 2;
				be1 = 1;
				w2.background = colorF;
				w1.background = colorW;
				slider.background = colorF;

				x.set(\inBus, ~eff1Bus);
				x.set(\outBus, ~eff2Bus);
				y.set(\inBus, ~inBus);
				y.set(\outBus, ~eff1Bus);
			}
			);
			if (l == 2, {
				x.moveAfter(z);
				a.layout_(
					VLayout(
					VLayout(
						HLayout(
							VLayout( [phaser, align:\top], VLayout(mixKnob3, mix3), HLayout( VLayout(freqKnob2, freq2)
								)),
							VLayout( [flanger, align:\top], VLayout(mixKnob, mix), HLayout( VLayout(feedbackKnob, feedback),
								VLayout(freqKnob, freq))),
							VLayout([wahwah, align:\top], VLayout(mixKnob2, mix2), HLayout( VLayout(bwKnob, bw),
								VLayout(cFreqKnob, cFreq))), slider
						), HLayout(VLayout(moveAfter1, bypass3),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass1),
							VLayout(moveBefore2, bypass2),r)
					), HLayout(scope, scope1), HLayout(inputText, outputText))
				).front;

				l = 1;
				j = 2;
				af1 = 3;
				be1 = 1;
				w2.background = colorF;
				w1.background = colorP;
				slider.background = colorF;

				x.set(\inBus, ~eff1Bus);
				x.set(\outBus, ~eff2Bus);
				z.set(\inBus, ~inBus);
				z.set(\outBus, ~eff1Bus);
			}
			);
		},
		2, {
			if(j == 2, {
				y.moveAfter(x);
				a.layout_(
						VLayout(
					VLayout(
						HLayout(
							VLayout( [flanger, align:\top], VLayout(mixKnob, mix), HLayout( VLayout(feedbackKnob, feedback),
								VLayout(freqKnob, freq))),
							VLayout([wahwah, align:\top], VLayout(mixKnob2, mix2), HLayout( VLayout(bwKnob, bw),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [phaser, align:\top], VLayout(mixKnob3, mix3), HLayout( VLayout(freqKnob2, freq2)
								)), slider
						), HLayout(VLayout(moveAfter1, bypass1),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass2),
							VLayout(moveBefore2, bypass3),r)
					), HLayout(scope, scope1), HLayout(inputText, outputText))
				).front;

				j = 1;
				k = 2;
				af1 = 1;
				be1 = 2;
				w1.background = colorF;
				w2.background = colorW;
				slider.background = colorW;


				y.set(\inBus, ~eff1Bus);
				y.set(\outBus, ~eff2Bus);
				x.set(\inBus, ~inBus);
				x.set(\outBus, ~eff1Bus);
			}
			);
			if (l == 2, {
				y.moveAfter(z);
				a.layout_(
						VLayout(
					VLayout(
						HLayout(
							VLayout( [phaser, align:\top], VLayout(mixKnob3, mix3), HLayout( VLayout(freqKnob2, freq2)
								)),
							VLayout([wahwah, align:\top], VLayout(mixKnob2, mix2), HLayout( VLayout(bwKnob, bw),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [flanger, align:\top], VLayout(mixKnob, mix), HLayout( VLayout(feedbackKnob, feedback),
								VLayout(freqKnob, freq))), slider
						), HLayout(VLayout(moveAfter1, bypass3),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass2),
							VLayout(moveBefore2, bypass1),r)
					), HLayout(scope, scope1), HLayout(inputText, outputText))
				).front;

				l = 1;
				k = 2;
				af1 = 3;
				be1 = 2;
				w2.background = colorW;
				w1.background = colorP;
				slider.background = colorW;

				y.set(\inBus, ~eff1Bus);
				y.set(\outBus, ~eff2Bus);
				z.set(\inBus, ~inBus);
				z.set(\outBus, ~eff1Bus);
			}
			);
		},
		3, {
			if(j == 2, {
				z.moveAfter(x);
				a.layout_(
							VLayout(
					VLayout(
						HLayout(
							VLayout( [flanger, align:\top], VLayout(mixKnob, mix), HLayout( VLayout(feedbackKnob, feedback),
								VLayout(freqKnob, freq))),
							VLayout( [phaser, align:\top], VLayout(mixKnob3, mix3), HLayout( VLayout(freqKnob2, freq2)
								)),
							VLayout([wahwah, align:\top], VLayout(mixKnob2, mix2), HLayout( VLayout(bwKnob, bw),
								VLayout(cFreqKnob, cFreq))), slider
						), HLayout(VLayout(moveAfter1, bypass1),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass3),
							VLayout(moveBefore2, bypass2),r)
					), HLayout(scope, scope1), HLayout(inputText, outputText))
				).front;

				j = 1;
				l = 2;
				af1 = 1;
				be1 = 3;
				w1.background = colorF;
				w2.background = colorP;
				slider.background = colorP;

				z.set(\inBus, ~eff1Bus);
				z.set(\outBus, ~eff2Bus);
				x.set(\inBus, ~inBus);
				x.set(\outBus, ~eff1Bus);
			}
			);
			if (k == 2, {
				z.moveAfter(y);
				a.layout_(
							VLayout(
					VLayout(
						HLayout(
							VLayout([wahwah, align:\top], VLayout(mixKnob2, mix2), HLayout( VLayout(bwKnob, bw),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [phaser, align:\top], VLayout(mixKnob3, mix3), HLayout( VLayout(freqKnob2, freq2)
								)),
							VLayout( [flanger, align:\top], VLayout(mixKnob, mix), HLayout( VLayout(feedbackKnob, feedback),
								VLayout(freqKnob, freq))), slider
						), HLayout(VLayout(moveAfter1, bypass2),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass3),
							VLayout(moveBefore2, bypass1),r)
					), HLayout(scope, scope1), HLayout(inputText, outputText))
				).front;

				k = 1;
				l = 2;
				af1 = 2;
				be1 = 3;
				w1.background = colorW;
				w2.background = colorP;
				slider.background = colorP;

				z.set(\inBus, ~eff1Bus);
				z.set(\outBus, ~eff2Bus);
				y.set(\inBus, ~inBus);
				y.set(\outBus, ~eff1Bus);
			}
			);
		}
	);
});

moveBefore1 = Button(a, Rect(440,425,205,20)).font_(fontButton);
moveBefore1.states_([["MOVE BEFORE", color1, Color.white]]);
moveBefore1.action_({
	switch(be1,
		1, {
			if(k == 1, {
				x.moveBefore(y);
				a.layout_(
									VLayout(
					VLayout(
						HLayout(
							VLayout( [flanger, align:\top], VLayout(mixKnob, mix), HLayout( VLayout(feedbackKnob, feedback),
								VLayout(freqKnob, freq)
								)),
							VLayout([wahwah, align:\top], VLayout(mixKnob2, mix2), HLayout( VLayout(bwKnob, bw),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [phaser, align:\top], VLayout(mixKnob3, mix3), HLayout( VLayout(freqKnob2, freq2)
								)), slider),
						HLayout(VLayout(moveAfter1, bypass1),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass2),
							VLayout(moveBefore2, bypass3),r)
					), HLayout(scope, scope1), HLayout(inputText, outputText))
				).front;

				k = 2;
				j = 1;
				be1 = 2;
				af1 = 1;
				w1.background = colorF;
				w2.background = colorW;
				slider.background = colorW;

				x.set(\inBus, ~inBus);
				x.set(\outBus, ~eff1Bus);
				y.set(\inBus, ~eff1Bus);
				y.set(\outBus, ~eff2Bus);
			}
			);
			if (l == 1, {
				x.moveBefore(z);
				a.layout_(
									VLayout(
					VLayout(
						HLayout(
							VLayout( [flanger, align:\top], VLayout(mixKnob, mix), HLayout( VLayout(feedbackKnob, feedback),
								VLayout(freqKnob, freq)
								)),
							VLayout( [phaser, align:\top], VLayout(mixKnob3, mix3), HLayout( VLayout(freqKnob2, freq2)
								)),
							VLayout([wahwah, align:\top], VLayout(mixKnob2, mix2), HLayout( VLayout(bwKnob, bw),
								VLayout(cFreqKnob, cFreq))), slider
						), HLayout(VLayout(moveAfter1, bypass1), VLayout(HLayout(moveBefore1, moveAfter2), bypass3), VLayout(moveBefore2, bypass2),r)
					), HLayout(scope, scope1), HLayout(inputText, outputText))
				).front;

				l = 2;
				j = 1;
				be1 = 3;
				af1 = 1;
				w1.background = colorF;
				w2.background = colorP;
				slider.background = colorP;

				x.set(\inBus, ~inBus);
				x.set(\outBus, ~eff1Bus);
				z.set(\inBus, ~eff1Bus);
				z.set(\outBus, ~eff2Bus);
			}
			);
		},
		2, {
			if(j == 1, {
				y.moveBefore(x);
				a.layout_(
										VLayout(
					VLayout(
						HLayout(
							VLayout([wahwah, align:\top], VLayout(mixKnob2, mix2), HLayout( VLayout(bwKnob, bw),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [flanger, align:\top], VLayout(mixKnob, mix), HLayout( VLayout(feedbackKnob, feedback),
								VLayout(freqKnob, freq)
								)),
							VLayout( [phaser, align:\top], VLayout(mixKnob3, mix3), HLayout( VLayout(freqKnob2, freq2)
								)), slider
						), HLayout(VLayout(moveAfter1, bypass2), VLayout(HLayout(moveBefore1, moveAfter2), bypass1), VLayout(moveBefore2, bypass3),r)
					), HLayout(scope, scope1), HLayout(inputText, outputText))
				).front;

				j = 2;
				k = 1;
				be1 = 1;
				af1 = 2;
				w2.background = colorF;
				w1.background = colorW;
				slider.background = colorF;


				y.set(\inBus, ~inBus);
				y.set(\outBus, ~eff1Bus);
				x.set(\inBus, ~eff1Bus);
				x.set(\outBus, ~eff2Bus);
			}
			);
			if (l == 1, {
				y.moveBefore(z);
				a.layout_(
										VLayout(
					VLayout(
						HLayout(
							VLayout([wahwah, align:\top], VLayout(mixKnob2, mix2), HLayout( VLayout(bwKnob, bw),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [phaser, align:\top], VLayout(mixKnob3, mix3), HLayout( VLayout(freqKnob2, freq2)
								)),
							VLayout( [flanger, align:\top], VLayout(mixKnob, mix), HLayout( VLayout(feedbackKnob, feedback),
								VLayout(freqKnob, freq)
								)), slider
						), HLayout(VLayout(moveAfter1, bypass2), VLayout(HLayout(moveBefore1, moveAfter2), bypass3), VLayout(moveBefore2, bypass1),r)
					), HLayout(scope, scope1), HLayout(inputText, outputText))
				).front;

				l = 2;
				k = 1;
				be1 = 3;
				af1 = 2;
				w1.background = colorW;
				w2.background = colorP;
				slider.background = colorP;

				y.set(\inBus, ~inBus);
				y.set(\outBus, ~eff1Bus);
				z.set(\inBus, ~eff1Bus);
				z.set(\outBus, ~eff2Bus);
			}
			);
		},
		3, {
			if(k == 1, {
				z.moveBefore(y);
				a.layout_(
											VLayout(
					VLayout(
						HLayout(
							VLayout( [phaser, align:\top], VLayout(mixKnob3, mix3), HLayout( VLayout(freqKnob2, freq2)
								)),
							VLayout([wahwah, align:\top], VLayout(mixKnob2, mix2), HLayout( VLayout(bwKnob, bw),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [flanger, align:\top], VLayout(mixKnob, mix), HLayout( VLayout(feedbackKnob, feedback),
								VLayout(freqKnob, freq)
								)), slider
						), HLayout(VLayout(moveAfter1, bypass1), VLayout(HLayout(moveBefore1, moveAfter2), bypass2), VLayout(moveBefore2, bypass3),r)
					), HLayout(scope, scope1), HLayout(inputText, outputText))
				).front;

				k = 2;
				l = 1;
				be1 = 2;
				af1 = 3;
				w2.background = colorW;
				w1.background = colorP;
				slider.background = colorW;

				z.set(\inBus, ~inBus);
				z.set(\outBus, ~eff1Bus);
				y.set(\inBus, ~eff1Bus);
				y.set(\outBus, ~eff2Bus);
			}
			);
			if (j == 1, {
				z.moveBefore(x);
				a.layout_(
											VLayout(
					VLayout(
						HLayout(
							VLayout( [phaser, align:\top], VLayout(mixKnob3, mix3), HLayout( VLayout(freqKnob2, freq2)
								)),
							VLayout( [flanger, align:\top], VLayout(mixKnob, mix), HLayout( VLayout(feedbackKnob, feedback),
								VLayout(freqKnob, freq)
								)),
							VLayout([wahwah, align:\top], VLayout(mixKnob2, mix2), HLayout( VLayout(bwKnob, bw),
								VLayout(cFreqKnob, cFreq))), slider
						), HLayout(VLayout(moveAfter1, bypass1), VLayout(HLayout(moveBefore1, moveAfter2), bypass3), VLayout(moveBefore2, bypass2),r)
					), HLayout(scope, scope1), HLayout(inputText, outputText))
				).front;

				j = 2;
				l = 1;
				be1 = 1;
				af1 = 3;
				w2.background = colorF;
				w1.background = colorP;
				slider.background = colorF;

				z.set(\inBus, ~inBus);
				z.set(\outBus, ~eff1Bus);
				x.set(\inBus, ~eff1Bus);
				x.set(\outBus, ~eff2Bus);
			}
			);
		}
	);
}
);

moveAfter2 = Button(a, Rect(655,425,205,20)).font_(fontButton);
moveAfter2.states_([["MOVE AFTER", color1, Color.white]]);
moveAfter2.action_({
	// be1 because it's in the same position as the button before
	switch(be1,
		1, {
			if(k == 3, {
				x.moveAfter(y);
				a.layout_(
													VLayout(
					VLayout(
						HLayout(
							VLayout( [phaser, align:\top], VLayout(mixKnob3, mix3), HLayout( VLayout(freqKnob2, freq2)
								)),
							VLayout([wahwah, align:\top], VLayout(mixKnob2, mix2), HLayout( VLayout(bwKnob, bw),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [flanger, align:\top], VLayout(mixKnob, mix), HLayout( VLayout(feedbackKnob, feedback),
								VLayout(freqKnob, freq)
								)), slider), HLayout(VLayout(moveAfter1, bypass3),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass2),
							VLayout(moveBefore2, bypass1),r)
					), HLayout(scope, scope1), HLayout(inputText, outputText))
				).front;

				k = 2;
				j = 3;
				be1 = 2;
				be2 = 1;
				w3.background = colorF;
				w2.background = colorW;
				slider.background = colorW;

				y.set(\inBus, ~eff1Bus);
				y.set(\outBus, ~eff2Bus);
				x.set(\inBus, ~eff2Bus);
				x.set(\outBus, ~outBus);
			}
			);
			if (l == 3, {
				x.moveAfter(z);
				a.layout_(
													VLayout(
					VLayout(
						HLayout(
							VLayout([wahwah, align:\top], VLayout(mixKnob2, mix2), HLayout( VLayout(bwKnob, bw),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [phaser, align:\top], VLayout(mixKnob3, mix3), HLayout( VLayout(freqKnob2, freq2)
								)),
							VLayout( [flanger, align:\top], VLayout(mixKnob, mix), HLayout( VLayout(feedbackKnob, feedback),
								VLayout(freqKnob, freq)
								)), slider

						), HLayout(VLayout(moveAfter1, bypass2),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass3),
							VLayout(moveBefore2, bypass1),r)
					), HLayout(scope, scope1), HLayout(inputText, outputText))
				).front;

				l = 2;
				j = 3;
				be1 = 3;
				be2 = 1;
				w3.background = colorF;
				w2.background = colorP;
				slider.background = colorP;

				z.set(\inBus, ~eff1Bus);
				z.set(\outBus, ~eff2Bus);
				x.set(\inBus, ~eff2Bus);
				x.set(\outBus, ~outBus);
			}
			);
		},
		2, {
			if(j == 3, {
				y.moveAfter(x);
				a.layout_(
														VLayout(
					VLayout(
						HLayout(
							VLayout( [phaser, align:\top], VLayout(mixKnob3, mix3), HLayout( VLayout(freqKnob2, freq2)
								)),
							VLayout( [flanger, align:\top], VLayout(mixKnob, mix), HLayout( VLayout(feedbackKnob, feedback),
								VLayout(freqKnob, freq)
								)),
							VLayout([wahwah, align:\top], VLayout(mixKnob2, mix2), HLayout( VLayout(bwKnob, bw),
								VLayout(cFreqKnob, cFreq))), slider), HLayout(VLayout(moveAfter1, bypass3),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass1),
							VLayout(moveBefore2, bypass2),r)
					), HLayout(scope, scope1), HLayout(inputText, outputText))
				).front;

				j = 2;
				k = 3;
				be1 = 1;
				be2 = 2;
				w2.background = colorF;
				w3.background = colorW;
				slider.background = colorF;

				x.set(\inBus, ~eff1Bus);
				x.set(\outBus, ~eff2Bus);
				y.set(\inBus, ~eff2Bus);
				y.set(\outBus, ~outBus);
			}
			);
			if (l == 3, {
				y.moveAfter(z);
				a.layout_(
														VLayout(
					VLayout(
						HLayout(
							VLayout( [flanger, align:\top], VLayout(mixKnob, mix), HLayout( VLayout(feedbackKnob, feedback),
								VLayout(freqKnob, freq)
								)),
							VLayout( [phaser, align:\top], VLayout(mixKnob3, mix3), HLayout( VLayout(freqKnob2, freq2)
								)),
							VLayout([wahwah, align:\top], VLayout(mixKnob2, mix2), HLayout( VLayout(bwKnob, bw),
								VLayout(cFreqKnob, cFreq))), slider), HLayout(VLayout(moveAfter1, bypass1),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass3),
							VLayout(moveBefore2, bypass2),r)
					), HLayout(scope, scope1), HLayout(inputText, outputText))
				).front;

				l = 2;
				k = 3;
				be1 = 3;
				be2 = 2;
				w3.background = colorW;
				w2.background = colorP;
				slider.background = colorP;

				z.set(\inBus, ~eff1Bus);
				z.set(\outBus, ~eff2Bus);
				y.set(\inBus, ~eff2Bus);
				y.set(\outBus, ~outBus);
			}
			);
		},
		3, {
			if(j == 3, {
				z.moveAfter(x);
				a.layout_(
															VLayout(
					VLayout(
						HLayout(
							VLayout([wahwah, align:\top], VLayout(mixKnob2, mix2), HLayout( VLayout(bwKnob, bw),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [flanger, align:\top], VLayout(mixKnob, mix), HLayout( VLayout(feedbackKnob, feedback),
								VLayout(freqKnob, freq)
								)),
							VLayout( [phaser, align:\top], VLayout(mixKnob3, mix3), HLayout( VLayout(freqKnob2, freq2)
								)), slider), HLayout(VLayout(moveAfter1, bypass2),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass1),
							VLayout(moveBefore2, bypass3),r)
					), HLayout(scope, scope1), HLayout(inputText, outputText))
				).front;

				j = 2;
				l = 3;
				be1 = 1;
				be2 = 3;
				w2.background = colorF;
				w3.background = colorP;
				slider.background = colorF;

				x.set(\inBus, ~eff1Bus);
				x.set(\outBus, ~eff2Bus);
				z.set(\inBus, ~eff2Bus);
				z.set(\outBus, ~outBus);
			}
			);
			if (k == 3, {
				z.moveAfter(y);
				a.layout_(
															VLayout(
					VLayout(
						HLayout(
							VLayout( [flanger, align:\top], VLayout(mixKnob, mix), HLayout( VLayout(feedbackKnob, feedback),
								VLayout(freqKnob, freq)
								)),
							VLayout([wahwah, align:\top], VLayout(mixKnob2, mix2), HLayout( VLayout(bwKnob, bw),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [phaser, align:\top], VLayout(mixKnob3, mix3), HLayout( VLayout(freqKnob2, freq2)
								)), slider), HLayout(VLayout(moveAfter1, bypass1),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass2),
							VLayout(moveBefore2, bypass3),r)
					), HLayout(scope, scope1), HLayout(inputText, outputText))
				).front;

				k = 2;
				l = 3;
				be1 = 2;
				be2 = 3;
				w2.background = colorW;
				w3.background = colorP;
				slider.background = colorW;

				y.set(\inBus, ~eff1Bus);
				y.set(\outBus, ~eff2Bus);
				z.set(\inBus, ~eff2Bus);
				z.set(\outBus, ~outBus);
			}
			);
		}
	);
});

moveBefore2 = Button(a, Rect(870,425,420,20)).font_(fontButton);
moveBefore2.states_([["MOVE BEFORE", color1, Color.white]]);
moveBefore2.action_({
	switch(be2,
		1, {
			if(k == 2, {
				x.moveBefore(y);
				a.layout_(
																	VLayout(
					VLayout(
						HLayout(
							VLayout( [phaser, align:\top], VLayout(mixKnob3, mix3), HLayout( VLayout(freqKnob2, freq2)
								)),
							VLayout( [flanger, align:\top], VLayout(mixKnob, mix), HLayout( VLayout(feedbackKnob, feedback),
								VLayout(freqKnob, freq)
								)),
							VLayout([wahwah, align:\top], VLayout(mixKnob2, mix2), HLayout( VLayout(bwKnob, bw),
								VLayout(cFreqKnob, cFreq))), slider),
						HLayout(VLayout(moveAfter1, bypass3),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass1),
							VLayout(moveBefore2, bypass2),r)
					), HLayout(scope, scope1), HLayout(inputText, outputText))
				).front;

				k = 3;
				j = 2;
				be2 = 2;
				be1 = 1;
				w2.background = colorF;
				w3.background = colorW;
				slider.background = colorF;

				x.set(\inBus, ~eff1Bus);
				x.set(\outBus, ~eff2Bus);
				y.set(\inBus, ~eff2Bus);
				y.set(\outBus, ~outBus);
			}
			);
			if (l == 2, {
				x.moveBefore(z);
				a.layout_(
																	VLayout(
					VLayout(
						HLayout(
							VLayout([wahwah, align:\top], VLayout(mixKnob2, mix2), HLayout( VLayout(bwKnob, bw),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [flanger, align:\top], VLayout(mixKnob, mix), HLayout( VLayout(feedbackKnob, feedback),
								VLayout(freqKnob, freq)
								)),
							VLayout( [phaser, align:\top], VLayout(mixKnob3, mix3), HLayout( VLayout(freqKnob2, freq2)
								)), slider),
						HLayout(VLayout(moveAfter1, bypass2), VLayout(HLayout(moveBefore1, moveAfter2), bypass1), VLayout(moveBefore2, bypass3),r)
					), HLayout(scope, scope1), HLayout(inputText, outputText))
				).front;

				l = 3;
				j = 2;
				be2 = 3;
				be1 = 1;
				w2.background = colorF;
				w3.background = colorP;
				slider.background = colorF;

				x.set(\inBus, ~eff1Bus);
				x.set(\outBus, ~eff2Bus);
				z.set(\inBus, ~eff2Bus);
				z.set(\outBus, ~outBus);
			}
			);
		},
		2, {
			if(j == 2, {
				y.moveBefore(x);
				a.layout_(
																		VLayout(
					VLayout(
						HLayout(
							VLayout( [phaser, align:\top], VLayout(mixKnob3, mix3), HLayout( VLayout(freqKnob2, freq2)
								)),
							VLayout([wahwah, align:\top], VLayout(mixKnob2, mix2), HLayout( VLayout(bwKnob, bw),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [flanger, align:\top], VLayout(mixKnob, mix), HLayout( VLayout(feedbackKnob, feedback),
								VLayout(freqKnob, freq)
								)), slider
						), HLayout(VLayout(moveAfter1, bypass3), VLayout(HLayout(moveBefore1, moveAfter2), bypass2), VLayout(moveBefore2, bypass1),r)
					), HLayout(scope, scope1), HLayout(inputText, outputText))
				).front;

				j = 3;
				k = 2;
				be2 = 1;
				be1 = 2;
				w3.background = colorF;
				w2.background = colorW;
				slider.background = colorW;

				y.set(\inBus, ~eff1Bus);
				y.set(\outBus, ~eff2Bus);
				x.set(\inBus, ~eff2Bus);
				x.set(\outBus, ~outBus);
			}
			);
			if (l == 2, {
				y.moveBefore(z);
				a.layout_(
																		VLayout(
					VLayout(
						HLayout(
							VLayout( [flanger, align:\top], VLayout(mixKnob, mix), HLayout( VLayout(feedbackKnob, feedback),
								VLayout(freqKnob, freq)
								)),
							VLayout([wahwah, align:\top], VLayout(mixKnob2, mix2), HLayout( VLayout(bwKnob, bw),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [phaser, align:\top], VLayout(mixKnob3, mix3), HLayout( VLayout(freqKnob2, freq2)
								)), slider), HLayout(VLayout(moveAfter1, bypass1), VLayout(HLayout(moveBefore1, moveAfter2), bypass2), VLayout(moveBefore2, bypass3),r)
					), HLayout(scope, scope1), HLayout(inputText, outputText))
				).front;

				l = 3;
				k = 2;
				be2 = 3;
				be1 = 2;
				w2.background = colorW;
				w3.background = colorP;
				slider.background = colorW;

				y.set(\inBus, ~eff1Bus);
				y.set(\outBus, ~eff2Bus);
				z.set(\inBus, ~eff2Bus);
				z.set(\outBus, ~outBus);
			}
			);
		},
		3, {
			if(k == 2, {
				z.moveBefore(y);
				a.layout_(
																			VLayout(
					VLayout(
						HLayout(
							VLayout( [flanger, align:\top], VLayout(mixKnob, mix), HLayout( VLayout(feedbackKnob, feedback),
								VLayout(freqKnob, freq)
								)),
							VLayout( [phaser, align:\top], VLayout(mixKnob3, mix3), HLayout( VLayout(freqKnob2, freq2)
								)),
							VLayout([wahwah, align:\top], VLayout(mixKnob2, mix2), HLayout( VLayout(bwKnob, bw),
								VLayout(cFreqKnob, cFreq))), slider), HLayout(VLayout(moveAfter1, bypass1), VLayout(HLayout(moveBefore1, moveAfter2), bypass3), VLayout(moveBefore2, bypass2),r)
					), HLayout(scope, scope1), HLayout(inputText, outputText))
				).front;

				k = 3;
				l = 2;
				be2 = 2;
				be1 = 3;
				w3.background = colorW;
				w2.background = colorP;
				slider.background = colorP;

				z.set(\inBus, ~eff1Bus);
				z.set(\outBus, ~eff2Bus);
				y.set(\inBus, ~eff2Bus);
				y.set(\outBus, ~outBus);
			}
			);
			if (j == 2, {
				z.moveBefore(x);
				a.layout_(
																			VLayout(
					VLayout(
						HLayout(
							VLayout([wahwah, align:\top], VLayout(mixKnob2, mix2), HLayout( VLayout(bwKnob, bw),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [phaser, align:\top], VLayout(mixKnob3, mix3), HLayout( VLayout(freqKnob2, freq2)
								)),
							VLayout( [flanger, align:\top], VLayout(mixKnob, mix), HLayout( VLayout(feedbackKnob, feedback),
								VLayout(freqKnob, freq)
								)), slider), HLayout(VLayout(moveAfter1, bypass2), VLayout(HLayout(moveBefore1, moveAfter2), bypass3), VLayout(moveBefore2, bypass1), r)
					), HLayout(scope, scope1), HLayout(inputText, outputText))
				).front;

				j = 3;
				l = 2;
				be2 = 1;
				be1 = 3;
				w3.background = colorF;
				w2.background = colorP;
				slider.background = colorP;

				z.set(\inBus, ~eff1Bus);
				z.set(\outBus, ~eff2Bus);
				x.set(\inBus, ~eff2Bus);
				x.set(\outBus, ~outBus);
			}
			);
		}
	);
}
);

a.layout_(
	VLayout(
	VLayout(
		HLayout(
				VLayout( [flanger, align:\top], VLayout(mixKnob, mix), HLayout( VLayout(feedbackKnob, feedback),
				VLayout(freqKnob, freq)
				)),
				VLayout([wahwah, align:\top], VLayout(mixKnob2, mix2), HLayout( VLayout(bwKnob, bw),
				VLayout(cFreqKnob, cFreq))),
			VLayout( [phaser, align:\top], VLayout(mixKnob3, mix3), HLayout( VLayout(freqKnob2, freq2)
				)), slider), HLayout(VLayout(moveAfter1, bypass1), VLayout(HLayout(moveBefore1, moveAfter2), bypass2), VLayout(moveBefore2, bypass3), r)
	), HLayout(scope, scope1), HLayout(inputText, outputText))
).front;
);
a.onClose = { scope.free;
	scope1.free;
};
)