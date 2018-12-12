import processing.svg.*;
JSONObject json;
int ppi = 300;
int width = 9*ppi; //9*300
int height = 12*ppi; //12*300
int borderMargin = 300;
int staffGap = 15;
int staffHeight = staffGap*4;
int staffWidth = width-borderMargin*2;
int spaceBetweenStaffs = staffHeight*2;
int numberOfStaffsPerPage = (height-borderMargin*2)/(staffHeight+spaceBetweenStaffs)+1;
int[] notes = {21,23,24,26,28,29,31,33,35,36,38,40,41,43,45,47,48,50,52,53,55,57,59,60,62,64,65,66,69,71,72,74,76,77,79,81,83,84,86,88,89,91,93,95,96,98,100,101,103,105,107,108};
float noteWidth = 4*staffGap;
float noteHeight = 4*staffGap;
// JSONObject noteFiles ={0.008:"note-128.svg",0.016:"note-64.svg",0.032:"note-32.svg",0.064:"note-16.svg",0.128:"note-8.svg",0.256:"note-4.svg",0.512:"note-2.svg",1.024:"note-1.svg"};
PShape clef;

PGraphics svg;

float measuresPerStaff = 6;
float tempo = 234; //quarter notes per minute
float measureTime = (60/tempo)*2; //seconds
float staffTime = measureTime*measuresPerStaff;

void setup() {

json = loadJSONObject("midi.json");

drawSheetMusic();
}
void drawStaffLines(int staffGp, int LocY){
	for (int i=0; i<5; i++){
		int y = i*staffGp+LocY;
		svg.line(borderMargin, borderMargin+y, width-borderMargin, borderMargin+y);
	}
}
void drawStaffs(){
	for (int i=0; i<numberOfStaffsPerPage; i++){
		int yOfStaff = i*(staffHeight+spaceBetweenStaffs);
		int yOfCleff = i*(staffHeight+spaceBetweenStaffs);
		float startXCleff = -staffGap;
		float startYCleff = -2.3*staffGap;
		// System.out.println(yOfStaff);
		drawStaffLines(staffGap, i*(staffHeight+spaceBetweenStaffs));
		drawClefs(startXCleff,startYCleff+i*(staffHeight+spaceBetweenStaffs));
	}
}
void drawClefs(float x, float y){
	clef = loadShape("clef.svg");
	svg.shape(clef, borderMargin+x, borderMargin+y, 6*staffGap, 8*staffGap);
}
// void isItNote(int midiNote){
//
// }
PShape whichNote(float duration){
	// for (int i; i < noteFiles)
	String fileName;
	if (duration <= 0.008){
		fileName = "note-128.svg";
	}else if(duration <= 0.016){
		fileName = "note-64.svg";
	}else if(duration <= 0.032){
		fileName = "note-32.svg";
	}else if(duration <= 0.064){
		fileName = "note-16.svg";
	}else if(duration <= 0.128){
		fileName = "note-8.svg";
	}else if(duration <= 0.256){
		fileName = "note-4.svg";
	}else if(duration <= 0.512){
		fileName = "note-2.svg";
	}else{// check if there are too long notes where you will need to combine more than one full notes
		fileName = "note-1.svg";
	}
	return loadShape(fileName);
}
float noteLocationOnStaff(int midiNote){
	int treble = 67;
	int g5sol = 79;
	int f5fa = 77;
	int f5faIndex = 33;
	int d4re = 62;
	int d4reIndex = 24;
	float y = -noteHeight/8;
	for (int i=0; i<notes.length; i++){
		if(midiNote==notes[i]){
			// println("yeees");
			y += (i-f5faIndex)*staffGap/2;
			break;
		}
		else{
			y = -noteHeight/8;
		}
		// if(f5fa == notes[i]){
		// 	println(i);
		// }
	}
	println(midiNote+", "+y);
	return y;
}
void drawNotes(JSONObject note){
	// println();
	String name = note.getString("name");
	int midi = note.getInt("midi");
	float time = note.getFloat("time");
	float velocity = note.getFloat("velocity");
	float duration = note.getFloat("duration");
	// println(time);
	//let's print only first page for now
	float pageTime = numberOfStaffsPerPage*staffTime;
	// println(time+", "+pageTime);
	if(time<=pageTime){
		// float m = map(time, 0, 100, 0, width);
		// println(time);
		int staffNo = int(time/staffTime)+1;
		// println(time+", staffno: "+staffNo);
		float y = (staffNo-1)*(staffHeight+spaceBetweenStaffs)+borderMargin;
		float finalY = noteLocationOnStaff(midi)+y;
		float x = map(time-(staffNo-1)*staffTime, 0, staffTime, borderMargin+staffHeight, width-borderMargin-4*staffGap);
		PShape noteSvg = whichNote(duration);
		svg.shape(noteSvg, x, finalY, noteWidth, noteHeight);

	}
	//do- midi 60 c4
	//re- midi 62 d4
	//mi
	//fa
	//sol
	//la
	//si
}
void drawSheetMusic(){
	svg = createGraphics(width, height, SVG, "output.svg");
	svg.beginDraw();
	svg.background(255,255,255);
	drawStaffs();
	JSONArray tracks = json.getJSONArray("tracks");
	JSONObject track1 = tracks.getJSONObject(1);
	JSONArray notes = track1.getJSONArray("notes");
	for (int i = 0; i < notes.size(); i++) {
			JSONObject note = notes.getJSONObject(i);
			drawNotes(note);
					// println("name: "+name + ", time: " + time + ", duration: " + duration);
		}
	svg.dispose();
	svg.endDraw();

}
// Sketch prints:
// 0, Panthera leo, Lion
