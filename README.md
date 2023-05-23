# group4-hw-SC-DrumTeam

Homework #1
<br> Multi effect: Flanger - Wah Wah - Phaser

Group composition:
<br> Brusca Alfredo 10936149
<br> Marazzi Alice 10625416
<br> Pomarico Riccardo 10661306

<img width="1462" alt="Screenshot 2023-05-23 alle 12 35 00" src="https://github.com/polimi-cmls-23/group4-hw-SC-DrumTeam/assets/79704727/6f15dff0-f142-4987-bd3c-25061f5e8bb4">

The goal of this project is to implement a multi effect able to manage Flanger, Wah Wah and Phaser effects and an interface to control it. We used a SynthDef for each effect, let’s analyze them one by one.

The code applies the effects on a wav file but the user can use their own input devices by uncommenting the line:

// sig = PlayBuf.ar(2, b, loop:1); // play the sample signal
<br> // sig = sig*0.5;
<br> sig = SoundIn.ar(0,2); // use the input device

The user can control some parameters for each effect, as well as the order of the three effects through “Move Before” and “Move After” buttons and also which effect to bypass or not by clicking on the Bypass button.
On the right side of the GUI there is a slider that controls the volume and a mute button.
Lastly, on the bottom of the window there is a signal visualization scope where the user can see both the input and the output signals.
