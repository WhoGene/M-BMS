# M-BMS
### Modular BMS High Level Control Logic
I'll be uploading here as I build the parts of it, and many aspects work standalone for multi-purpose like the following:

# Time per battery load current a5.lisp
It's a vesc based battery load testing utitity ideal for:
###  - checking varous configurations aginst each other
###  - validating power delivery
###  - determining relationship between loaded and unloaded voltages under amp load
###  - cell health checkup as it ages

### Pack to Cell Conversions
It takes your s and p count from your pack and calculates the cell values after loading the whole pack.
You will need to have vesc hooked up to a motor or other resistive block where the 3 pahse wires can dump the shorted energy for the duration of the test

It should output the following after you upload it:
### "test time"
2.359900f32
### "end phase current"
68.875969f32
### "start voltage"
3.423788f32
### "end voltage"
3.227900f32
### "v-sag"
0.195851f32
### "Cell Load at the following amps:"
10.196529f32
### "VESC Load Resistance mOhms at 20khz switch mode"
0.316568f32
###"cell mOhms"
0.019211f32
