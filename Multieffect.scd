s.boot

(
var sig, sigF, sigW, sigP;
var outF, outW, outP;
var mfreqF, mfreqW, mfreqP;
var lfoW, lfoP;
var freqW, freqP;
var depthF, depthP;
var cFreqW, cFreqP;
var cFreq;
var depth, depth2;
var freq, freq2, freq3;
var x, mod1, maxfreq, maxdepth, maxdelay, basedelay;
var cutoff, resonance, mix;
var delay, feedback;
var delayKnob, freqKnob, freqKnob2,depthKnob, cFreqKnob, panSlider, freqKnob3, depthKnob2, bypass1, bypass2, bypass3;
var moveBefore1, moveAfter1, moveBefore2, moveAfter2, flanger, wahwah, phaser;
var be1, be2, af1;
var w1, w2, w3;
var fontTitle, fontKnob, fontButton;
var color1, colorF, colorW, colorP;

(
SynthDef("flange", {arg inBus, outBus;
	maxfreq=10;
	maxdelay=0.5;
	basedelay=maxdelay/2;
	maxdepth=1;
	depthF = maxdepth/2;
	mfreqF = maxfreq/2;
	mod1 = SinOsc.ar(mfreqF,0, depthF);
	sigF =  In.ar(inBus, 1);
	outF = DelayC.ar(sigF, maxdelay,basedelay + mod1);
	outF = Mix.ar([outF,sigF]);
	if (~flangerActive == 1, {
		Out.ar (outBus, outF);
	}, {
		Out.ar (outBus, sigF);
	});
}).send(s);
);

(
SynthDef("wah", {arg inBus, outBus;
	mix = 0.5;
	sigW = In.ar(inBus, 1);
	mfreqW = 0.25;
	cFreqW = 800;
	lfoW = SinOsc.kr(mfreqW).range(0, 1);
	cutoff = cFreqW + (lfoW * 400);
	resonance = 0.5;
	freqW = Lag.kr(cutoff, 0.1);
	outW = BPF.ar(sigW, freqW, resonance);
	outW = Mix.ar([outW*mix, sigW*(1-mix)]);
	if (~wahActive == 1, {
		Out.ar (outBus, outW);
	}, {
		Out.ar (outBus, sigW);
	});
}).send(s);
);

(
SynthDef("phaser", {arg inBus, outBus;
	sigP = In.ar(inBus, 1);
	mfreqP = 0.5;
	lfoP = SinOsc.kr(mfreqP).range(0, 1);
	cFreqP = 0.1;
	freqP = cFreqP + (lfoP * 0.1);
	depthP = 0.5;
	delay = CombL.ar(sigP, 0.05, depthP, freqP);
	feedback = 0.5;
	delay = AllpassN.ar(delay, 0.05, { cFreqP + (lfoP * 0.1) }, 1);
	outP = Mix.ar([sigP, delay]) * feedback;
	if (~phaserActive == 1, {
		Out.ar (outBus, outP);
	}, {
		Out.ar (outBus, sigP);
	});
}).send(s);
);

(
~inBus = Bus.audio(s, 1);
~eff1Bus = Bus.audio(s, 1);
~eff2Bus = Bus.audio(s, 1);
);

(
x = Synth.new(\flange, [\inBus, ~inBus, \outBus, ~eff1Bus]);
y = Synth.after(x, \wah, [\inBus, ~eff1Bus, \outBus, ~eff2Bus]);
z = Synth.after(y, \phaser,  [\inBus, ~eff2Bus, \outBus, 0]);
);

(
{
	sig = SoundIn.ar(0, 1);
	Out.ar(~inBus, sig);
}.play;
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


~flangerActive = 1;
~wahActive = 1;
~phaserActive = 1;

a = Window.new(bounds: Rect(128, 150, 1300, 500), resizable: false).background_(color1);

w1 = CompositeView(a, Rect(10,10,420,410)).background_(colorF);

w2 = CompositeView(a, Rect(440,10,420,410)).background_(colorW);

w3 = CompositeView(a, Rect(870,10,420,410)).background_(colorP);

depthKnob = Knob(a);
freqKnob = Knob(a);
delayKnob = Knob(a);

depthKnob.action_({
	x.set(\depthF, depthKnob.value*0.1);
});
freqKnob.action_({
	x.set(\mfreqF, freqKnob.value*3);
});
delayKnob.action_({
	x.set(\basedelayF, delayKnob.value*0.1);
});


depthKnob.color = [color1, color1, colorF, colorF];
freqKnob.color = [color1, color1, colorF, colorF];
delayKnob.color = [color1, color1, colorF, colorF];


freqKnob2 = Knob(a);
cFreqKnob = Knob(a);

freqKnob2.action_({
	y.set(\mfreqW, freqKnob2.value*0.5);
});
cFreqKnob.action_({
	y.set(\cFreqW, cFreqKnob.value*1600);
});

cFreqKnob.color = [color1, color1, colorW, colorW];
freqKnob2.color = [color1, color1, colorW, colorW];

freqKnob3 = Knob(a);
depthKnob2 = Knob(a);

freqKnob3.action_({
	z.set(\mfreqP, freqKnob3.value);
});
depthKnob2.action_({
	z.set(\depthP, depthKnob2.value);
});

depthKnob2.color = [color1, color1, colorP, colorP];
freqKnob3.color = [color1, color1, colorP, colorP];

bypass1 = Button().font_(fontButton);
bypass1.states = [["BYPASS", color1, Color.cyan], ["BYPASSED", Color.cyan, color1]];
bypass1.action({
	if (~flangerActive == 1, {
		~flangerActive = 0;
	}, {
		~flangerActive = 1;
	}
	);
});

bypass2 = Button().font_(fontButton);
bypass2.states = [["BYPASS", color1, Color.cyan], ["BYPASSED", Color.cyan, color1]];
bypass2.action({
	if (~wahActive == 1, {
		~wahActive = 0;
	}, {
		~wahActive = 1;
	}
	);
});

bypass3 = Button().font_(fontButton);
bypass3.states = [["BYPASS", color1, Color.cyan], ["BYPASSED", Color.cyan, color1]];
bypass3.action_({
	if (~phaserActive == 1, {
		~phaserActive = 0;
	}, {
		~phaserActive = 1;
	}
	);
});



flanger = StaticText().string_("FLANGER").font_(fontTitle).stringColor_(color1).align_(\center);
wahwah = StaticText().string_("WAH WAH").font_(fontTitle).stringColor_(color1).align_(\center);
phaser = StaticText().string_("PHASER").font_(fontTitle).stringColor_(color1).align_(\center);
depth = StaticText().string_("depth").font_(fontKnob).stringColor_(color1).align_(\center);
freq = StaticText().string_("freq").font_(fontKnob).stringColor_(color1).align_(\center);
delay = StaticText().string_("delay").font_(fontKnob).stringColor_(color1).align_(\center);
cFreq = StaticText().string_("c freq").font_(fontKnob).stringColor_(color1).align_(\center);
freq2 = StaticText().string_("freq").font_(fontKnob).stringColor_(color1).align_(\center);
freq3 = StaticText().string_("freq").font_(fontKnob).stringColor_(color1).align_(\center);
depth2 = StaticText().string_("depth").font_(fontKnob).stringColor_(color1).align_(\center);

moveAfter1 = Button().font_(fontButton);
moveAfter1.states_([["MOVE AFTER", color1, Color.white]]);
moveAfter1.action_({
	switch(af1,
		1, {
			if(k == 2, {
				x.moveAfter(y);
				a.layout_(
					VLayout(
						HLayout(
							VLayout([wahwah, align:\top], HLayout( VLayout(freqKnob2, freq2),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [flanger, align:\top], HLayout( VLayout(depthKnob, depth),
								VLayout(freqKnob, freq),
								VLayout(delayKnob, delay))),
							VLayout( [phaser, align:\top], HLayout( VLayout(freqKnob3, freq3),
								VLayout(depthKnob2, depth2)))
						), HLayout(VLayout(moveAfter1, bypass2),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass1),
							VLayout(moveBefore2, bypass3))
					)
				).front;

				k = 1;
				j = 2;
				af1 = 2;
				be1 = 1;
				w2.background = colorF;
				w1.background = colorW;

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
						HLayout(
							VLayout( [phaser, align:\top], HLayout( VLayout(freqKnob3, freq3),
								VLayout(depthKnob2, depth2))),
							VLayout( [flanger, align:\top], HLayout( VLayout(depthKnob, depth),
								VLayout(freqKnob, freq),
								VLayout(delayKnob, delay))),
							VLayout([wahwah, align:\top], HLayout( VLayout(freqKnob2, freq2),
								VLayout(cFreqKnob, cFreq)))
						), HLayout(VLayout(moveAfter1, bypass3),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass1),
							VLayout(moveBefore2, bypass2))
					)
				).front;

				l = 1;
				j = 2;
				af1 = 3;
				be1 = 1;
				w2.background = colorF;
				w1.background = colorP;

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
						HLayout(
							VLayout( [flanger, align:\top], HLayout( VLayout(depthKnob, depth),
								VLayout(freqKnob, freq),
								VLayout(delayKnob, delay))),
							VLayout([wahwah, align:\top], HLayout( VLayout(freqKnob2, freq2),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [phaser, align:\top], HLayout( VLayout(freqKnob3, freq3),
								VLayout(depthKnob2, depth2)))
						), HLayout(VLayout(moveAfter1, bypass1),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass2),
							VLayout(moveBefore2, bypass3))
					)
				).front;

				j = 1;
				k = 2;
				af1 = 1;
				be1 = 2;
		w1.background = colorF;
			w2.background = colorW;


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
						HLayout(
							VLayout( [phaser, align:\top], HLayout( VLayout(freqKnob3, freq3),
								VLayout(depthKnob2, depth2))),
							VLayout([wahwah, align:\top], HLayout( VLayout(freqKnob2, freq2),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [flanger, align:\top], HLayout( VLayout(depthKnob, depth),
								VLayout(freqKnob, freq),
								VLayout(delayKnob, delay)))
						), HLayout(VLayout(moveAfter1, bypass3),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass2),
							VLayout(moveBefore2, bypass1))
					)
				).front;

				l = 1;
				k = 2;
				af1 = 3;
				be1 = 2;
			w2.background = colorW;
			w1.background = colorP;

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
						HLayout(
							VLayout( [flanger, align:\top], HLayout( VLayout(depthKnob, depth),
								VLayout(freqKnob, freq),
								VLayout(delayKnob, delay))),
							VLayout( [phaser, align:\top], HLayout( VLayout(freqKnob3, freq3),
								VLayout(depthKnob2, depth2))),
							VLayout([wahwah, align:\top], HLayout( VLayout(freqKnob2, freq2),
								VLayout(cFreqKnob, cFreq)))
						), HLayout(VLayout(moveAfter1, bypass1),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass3),
							VLayout(moveBefore2, bypass2))
					)
				).front;

				j = 1;
				l = 2;
				af1 = 1;
				be1 = 3;
		w1.background = colorF;

			w2.background = colorP;

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
						HLayout(
							VLayout([wahwah, align:\top], HLayout( VLayout(freqKnob2, freq2),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [phaser, align:\top], HLayout( VLayout(freqKnob3, freq3),
								VLayout(depthKnob2, depth2))),
							VLayout( [flanger, align:\top], HLayout( VLayout(depthKnob, depth),
								VLayout(freqKnob, freq),
								VLayout(delayKnob, delay)))
						), HLayout(VLayout(moveAfter1, bypass2),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass3),
							VLayout(moveBefore2, bypass1))
					)
				).front;

				k = 1;
				l = 2;
				af1 = 2;
				be1 = 3;
			w1.background = colorW;
			w2.background = colorP;

				z.set(\inBus, ~eff1Bus);
				z.set(\outBus, ~eff2Bus);
				y.set(\inBus, ~inBus);
				y.set(\outBus, ~eff1Bus);
			}
			);
		}
	);
});

moveBefore1 = Button().font_(fontButton);
moveBefore1.states_([["MOVE BEFORE", color1, Color.white]]);
moveBefore1.action_({
	switch(be1,
		1, {
			if(k == 1, {
				x.moveBefore(y);
				a.layout_(
					VLayout(
						HLayout(
							VLayout( [flanger, align:\top], HLayout( VLayout(depthKnob, depth),
								VLayout(freqKnob, freq),
								VLayout(delayKnob, delay))),
							VLayout([wahwah, align:\top], HLayout( VLayout(freqKnob2, freq2),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [phaser, align:\top], HLayout( VLayout(freqKnob3, freq3),
								VLayout(depthKnob2, depth2)))),
						HLayout(VLayout(moveAfter1, bypass1),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass2),
							VLayout(moveBefore2, bypass3))
					)
				).front;

				k = 2;
				j = 1;
				be1 = 2;
				af1 = 1;
				w1.background = colorF;
			w2.background = colorW;

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
						HLayout(
							VLayout( [flanger, align:\top], HLayout( VLayout(depthKnob, depth),
								VLayout(freqKnob, freq),
								VLayout(delayKnob, delay))),
							VLayout( [phaser, align:\top], HLayout( VLayout(freqKnob3, freq3),
								VLayout(depthKnob2, depth2))),
							VLayout([wahwah, align:\top], HLayout( VLayout(freqKnob2, freq2),
								VLayout(cFreqKnob, cFreq)))
						), HLayout(VLayout(moveAfter1, bypass1), VLayout(HLayout(moveBefore1, moveAfter2), bypass3), VLayout(moveBefore2, bypass2))
					)
				).front;

				l = 2;
				j = 1;
				be1 = 3;
				af1 = 1;
		w1.background = colorF;
			w2.background = colorP;

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
						HLayout(
							VLayout([wahwah, align:\top], HLayout( VLayout(freqKnob2, freq2),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [flanger, align:\top], HLayout( VLayout(depthKnob, depth),
								VLayout(freqKnob, freq),
								VLayout(delayKnob, delay))),
							VLayout( [phaser, align:\top], HLayout( VLayout(freqKnob3, freq3),
								VLayout(depthKnob2, depth2)))
						), HLayout(VLayout(moveAfter1, bypass2), VLayout(HLayout(moveBefore1, moveAfter2), bypass1), VLayout(moveBefore2, bypass3))
					)
				).front;

				j = 2;
				k = 1;
				be1 = 1;
				af1 = 2;
		w2.background = colorF;
			w1.background = colorW;


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
						HLayout(
							VLayout([wahwah, align:\top], HLayout( VLayout(freqKnob2, freq2),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [phaser, align:\top], HLayout( VLayout(freqKnob3, freq3),
								VLayout(depthKnob2, depth2))),
							VLayout( [flanger, align:\top], HLayout( VLayout(depthKnob, depth),
								VLayout(freqKnob, freq),
								VLayout(delayKnob, delay)))
						), HLayout(VLayout(moveAfter1, bypass2), VLayout(HLayout(moveBefore1, moveAfter2), bypass3), VLayout(moveBefore2, bypass1))
					)
				).front;

				l = 2;
				k = 1;
				be1 = 3;
				af1 = 2;

			w1.background = colorW;
			w2.background = colorP;

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
						HLayout(
							VLayout( [phaser, align:\top], HLayout( VLayout(freqKnob3, freq3),
								VLayout(depthKnob2, depth2))),
							VLayout([wahwah, align:\top], HLayout( VLayout(freqKnob2, freq2),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [flanger, align:\top], HLayout( VLayout(depthKnob, depth),
								VLayout(freqKnob, freq),
								VLayout(delayKnob, delay)))
						), HLayout(VLayout(moveAfter1, bypass1), VLayout(HLayout(moveBefore1, moveAfter2), bypass2), VLayout(moveBefore2, bypass3))
					)
				).front;

				k = 2;
				l = 1;
				be1 = 2;
				af1 = 3;

			w2.background = colorW;
			w1.background = colorP;

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
						HLayout(
							VLayout( [phaser, align:\top], HLayout( VLayout(freqKnob3, freq3),
								VLayout(depthKnob2, depth2))),
							VLayout( [flanger, align:\top], HLayout( VLayout(depthKnob, depth),
								VLayout(freqKnob, freq),
								VLayout(delayKnob, delay))),
							VLayout([wahwah, align:\top], HLayout( VLayout(freqKnob2, freq2),
								VLayout(cFreqKnob, cFreq)))
						), HLayout(VLayout(moveAfter1, bypass1), VLayout(HLayout(moveBefore1, moveAfter2), bypass3), VLayout(moveBefore2, bypass2))
					)
				).front;

				j = 2;
				l = 1;
				be1 = 1;
				af1 = 3;
	w2.background = colorF;

			w1.background = colorP;

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

moveAfter2 = Button().font_(fontButton);
moveAfter2.states_([["MOVE AFTER", color1, Color.white]]);
moveAfter2.action_({
	// be1 because it's in the same position as the button before
	switch(be1,
		1, {
			if(k == 3, {
				x.moveAfter(y);
				a.layout_(
					VLayout(
						HLayout(
							VLayout( [phaser, align:\top], HLayout( VLayout(freqKnob3, freq3),
								VLayout(depthKnob2, depth2))),
							VLayout([wahwah, align:\top], HLayout( VLayout(freqKnob2, freq2),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [flanger, align:\top], HLayout( VLayout(depthKnob, depth),
								VLayout(freqKnob, freq),
								VLayout(delayKnob, delay)))), HLayout(VLayout(moveAfter1, bypass3),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass2),
							VLayout(moveBefore2, bypass1))
					)
				).front;

				k = 2;
				j = 3;
				be1 = 2;
				be2 = 1;
				w3.background = colorF;
			w2.background = colorW;


				y.set(\inBus, ~eff1Bus);
				y.set(\outBus, ~eff2Bus);
				x.set(\inBus, ~eff2Bus);
				x.set(\outBus, 0);
			}
			);
			if (l == 3, {
				x.moveAfter(z);
				a.layout_(
					VLayout(
						HLayout(
							VLayout([wahwah, align:\top], HLayout( VLayout(freqKnob2, freq2),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [phaser, align:\top], HLayout( VLayout(freqKnob3, freq3),
								VLayout(depthKnob2, depth2))),
							VLayout( [flanger, align:\top], HLayout( VLayout(depthKnob, depth),
								VLayout(freqKnob, freq),
								VLayout(delayKnob, delay)))

						), HLayout(VLayout(moveAfter1, bypass2),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass3),
							VLayout(moveBefore2, bypass1))
					)
				).front;

				l = 2;
				j = 3;
				be1 = 3;
				be2 = 1;
		w3.background = colorF;
			w2.background = colorP;

				z.set(\inBus, ~eff1Bus);
				z.set(\outBus, ~eff2Bus);
				x.set(\inBus, ~eff2Bus);
				x.set(\outBus, 0);
			}
			);
		},
		2, {
			if(j == 3, {
				y.moveAfter(x);
				a.layout_(
					VLayout(
						HLayout(
							VLayout( [phaser, align:\top], HLayout( VLayout(freqKnob3, freq3),
								VLayout(depthKnob2, depth2))),
							VLayout( [flanger, align:\top], HLayout( VLayout(depthKnob, depth),
								VLayout(freqKnob, freq),
								VLayout(delayKnob, delay))),
							VLayout([wahwah, align:\top], HLayout( VLayout(freqKnob2, freq2),
								VLayout(cFreqKnob, cFreq)))), HLayout(VLayout(moveAfter1, bypass3),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass1),
							VLayout(moveBefore2, bypass2))
					)
				).front;

				j = 2;
				k = 3;
				be1 = 1;
				be2 = 2;
		w2.background = colorF;
			w3.background = colorW;


				x.set(\inBus, ~eff1Bus);
				x.set(\outBus, ~eff2Bus);
				y.set(\inBus, ~eff2Bus);
				y.set(\outBus, 0);
			}
			);
			if (l == 3, {
				y.moveAfter(z);
				a.layout_(
					VLayout(
						HLayout(
							VLayout( [flanger, align:\top], HLayout( VLayout(depthKnob, depth),
								VLayout(freqKnob, freq),
								VLayout(delayKnob, delay))),
							VLayout( [phaser, align:\top], HLayout( VLayout(freqKnob3, freq3),
								VLayout(depthKnob2, depth2))),
							VLayout([wahwah, align:\top], HLayout( VLayout(freqKnob2, freq2),
								VLayout(cFreqKnob, cFreq)))), HLayout(VLayout(moveAfter1, bypass1),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass3),
							VLayout(moveBefore2, bypass2))
					)
				).front;

				l = 2;
				k = 3;
				be1 = 3;
				be2 = 2;

			w3.background = colorW;
			w2.background = colorP;

				z.set(\inBus, ~eff1Bus);
				z.set(\outBus, ~eff2Bus);
				y.set(\inBus, ~eff2Bus);
				y.set(\outBus, 0);
			}
			);
		},
		3, {
			if(j == 3, {
				z.moveAfter(x);
				a.layout_(
					VLayout(
						HLayout(
							VLayout([wahwah, align:\top], HLayout( VLayout(freqKnob2, freq2),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [flanger, align:\top], HLayout( VLayout(depthKnob, depth),
								VLayout(freqKnob, freq),
								VLayout(delayKnob, delay))),
							VLayout( [phaser, align:\top], HLayout( VLayout(freqKnob3, freq3),
								VLayout(depthKnob2, depth2)))), HLayout(VLayout(moveAfter1, bypass2),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass1),
							VLayout(moveBefore2, bypass3))
					)
				).front;

				j = 2;
				l = 3;
				be1 = 1;
				be2 = 3;
		w2.background = colorF;
			w3.background = colorP;

				x.set(\inBus, ~eff1Bus);
				x.set(\outBus, ~eff2Bus);
				z.set(\inBus, ~eff2Bus);
				z.set(\outBus, 0);
			}
			);
			if (k == 3, {
				z.moveAfter(y);
				a.layout_(
					VLayout(
						HLayout(
							VLayout( [flanger, align:\top], HLayout( VLayout(depthKnob, depth),
								VLayout(freqKnob, freq),
								VLayout(delayKnob, delay))),
							VLayout([wahwah, align:\top], HLayout( VLayout(freqKnob2, freq2),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [phaser, align:\top], HLayout( VLayout(freqKnob3, freq3),
								VLayout(depthKnob2, depth2)))), HLayout(VLayout(moveAfter1, bypass1),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass2),
							VLayout(moveBefore2, bypass3))
					)
				).front;

				k = 2;
				l = 3;
				be1 = 2;
				be2 = 3;
			w2.background = colorW;
			w3.background = colorP;

				y.set(\inBus, ~eff1Bus);
				y.set(\outBus, ~eff2Bus);
				z.set(\inBus, ~eff2Bus);
				z.set(\outBus, 0);
			}
			);
		}
	);
});

moveBefore2 = Button().font_(fontButton);
moveBefore2.states_([["MOVE BEFORE", color1, Color.white]]);
moveBefore2.action_({
	switch(be2,
		1, {
			if(k == 2, {
				x.moveBefore(y);
				a.layout_(
					VLayout(
						HLayout(
							VLayout( [phaser, align:\top], HLayout( VLayout(freqKnob3, freq3),
								VLayout(depthKnob2, depth2))),
							VLayout( [flanger, align:\top], HLayout( VLayout(depthKnob, depth),
								VLayout(freqKnob, freq),
								VLayout(delayKnob, delay))),
							VLayout([wahwah, align:\top], HLayout( VLayout(freqKnob2, freq2),
								VLayout(cFreqKnob, cFreq)))),
						HLayout(VLayout(moveAfter1, bypass3),
							VLayout(HLayout(moveBefore1, moveAfter2), bypass1),
							VLayout(moveBefore2, bypass2))
					)
				).front;

				k = 3;
				j = 2;
				be2 = 2;
				be1 = 1;
				w2.background = colorF;
			w3.background = colorW;

				x.set(\inBus, ~eff1Bus);
				x.set(\outBus, ~eff2Bus);
				y.set(\inBus, ~eff2Bus);
				y.set(\outBus, 0);
			}
			);
			if (l == 2, {
				x.moveBefore(z);
				a.layout_(
					VLayout(
						HLayout(
							VLayout([wahwah, align:\top], HLayout( VLayout(freqKnob2, freq2),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [flanger, align:\top], HLayout( VLayout(depthKnob, depth),
								VLayout(freqKnob, freq),
								VLayout(delayKnob, delay))),
							VLayout( [phaser, align:\top], HLayout( VLayout(freqKnob3, freq3),
								VLayout(depthKnob2, depth2)))),
						HLayout(VLayout(moveAfter1, bypass2), VLayout(HLayout(moveBefore1, moveAfter2), bypass1), VLayout(moveBefore2, bypass3))
					)
				).front;

				l = 3;
				j = 2;
				be2 = 3;
				be1 = 1;
		w2.background = colorF;
			w3.background = colorP;

				x.set(\inBus, ~eff1Bus);
				x.set(\outBus, ~eff2Bus);
				z.set(\inBus, ~eff2Bus);
				z.set(\outBus, 0);
			}
			);
		},
		2, {
			if(j == 2, {
				y.moveBefore(x);
				a.layout_(
					VLayout(
						HLayout(
							VLayout( [phaser, align:\top], HLayout( VLayout(freqKnob3, freq3),
								VLayout(depthKnob2, depth2))),
							VLayout([wahwah, align:\top], HLayout( VLayout(freqKnob2, freq2),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [flanger, align:\top], HLayout( VLayout(depthKnob, depth),
								VLayout(freqKnob, freq),
								VLayout(delayKnob, delay)))
						), HLayout(VLayout(moveAfter1, bypass3), VLayout(HLayout(moveBefore1, moveAfter2), bypass2), VLayout(moveBefore2, bypass1))
					)
				).front;

				j = 3;
				k = 2;
				be2 = 1;
				be1 = 2;
		w3.background = colorF;
			w2.background = colorW;

				y.set(\inBus, ~eff1Bus);
				y.set(\outBus, ~eff2Bus);
				x.set(\inBus, ~eff2Bus);
				x.set(\outBus, 0);
			}
			);
			if (l == 2, {
				y.moveBefore(z);
				a.layout_(
					VLayout(
						HLayout(
							VLayout( [flanger, align:\top], HLayout( VLayout(depthKnob, depth),
								VLayout(freqKnob, freq),
								VLayout(delayKnob, delay))),
							VLayout([wahwah, align:\top], HLayout( VLayout(freqKnob2, freq2),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [phaser, align:\top], HLayout( VLayout(freqKnob3, freq3),
								VLayout(depthKnob2, depth2)))
						), HLayout(VLayout(moveAfter1, bypass1), VLayout(HLayout(moveBefore1, moveAfter2), bypass2), VLayout(moveBefore2, bypass3))
					)
				).front;

				l = 3;
				k = 2;
				be2 = 3;
				be1 = 2;
			w2.background = colorW;
			w3.background = colorP;

				y.set(\inBus, ~eff1Bus);
				y.set(\outBus, ~eff2Bus);
				z.set(\inBus, ~eff2Bus);
				z.set(\outBus, 0);
			}
			);
		},
		3, {
			if(k == 2, {
				z.moveBefore(y);
				a.layout_(
					VLayout(
						HLayout(
							VLayout( [flanger, align:\top], HLayout( VLayout(depthKnob, depth),
								VLayout(freqKnob, freq),
								VLayout(delayKnob, delay))),
							VLayout( [phaser, align:\top], HLayout( VLayout(freqKnob3, freq3),
								VLayout(depthKnob2, depth2))),
							VLayout([wahwah, align:\top], HLayout( VLayout(freqKnob2, freq2),
								VLayout(cFreqKnob, cFreq)))
						), HLayout(VLayout(moveAfter1, bypass1), VLayout(HLayout(moveBefore1, moveAfter2), bypass3), VLayout(moveBefore2, bypass2))
					)
				).front;

				k = 3;
				l = 2;
				be2 = 2;
				be1 = 3;
			w3.background = colorW;
			w2.background = colorP;

				z.set(\inBus, ~eff1Bus);
				z.set(\outBus, ~eff2Bus);
				y.set(\inBus, ~eff2Bus);
				y.set(\outBus, 0);
			}
			);
			if (j == 2, {
				z.moveBefore(x);
				a.layout_(
					VLayout(
						HLayout(
							VLayout([wahwah, align:\top], HLayout( VLayout(freqKnob2, freq2),
								VLayout(cFreqKnob, cFreq))),
							VLayout( [phaser, align:\top], HLayout( VLayout(freqKnob3, freq3),
								VLayout(depthKnob2, depth2))),
							VLayout( [flanger, align:\top], HLayout( VLayout(depthKnob, depth),
								VLayout(freqKnob, freq),
								VLayout(delayKnob, delay)))
						), HLayout(VLayout(moveAfter1, bypass2), VLayout(HLayout(moveBefore1, moveAfter2), bypass3), VLayout(moveBefore2, bypass1))
					)
				).front;

				j = 3;
				l = 2;
				be2 = 1;
				be1 = 3;
	w3.background = colorF;
			w2.background = colorP;

				z.set(\inBus, ~eff1Bus);
				z.set(\outBus, ~eff2Bus);
				x.set(\inBus, ~eff2Bus);
				x.set(\outBus, 0);
			}
			);
		}
	);
}
);

a.layout_(
	VLayout(
		HLayout(
			VLayout( [flanger, align:\top], HLayout( VLayout(depthKnob, depth),
				VLayout(freqKnob, freq),
				VLayout(delayKnob, delay))),
			VLayout([wahwah, align:\top], HLayout( VLayout(freqKnob2, freq2),
				VLayout(cFreqKnob, cFreq))),
			VLayout( [phaser, align:\top], HLayout( VLayout(freqKnob3, freq3),
				VLayout(depthKnob2, depth2)))
		), HLayout(VLayout(moveAfter1, bypass1), VLayout(HLayout(moveBefore1, moveAfter2), bypass2), VLayout(moveBefore2, bypass3))
	)
).front;
);

)