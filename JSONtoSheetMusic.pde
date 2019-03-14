import processing.svg.*;
import java.util.Date;
import processing.pdf.*;
PrintWriter output;
PrintWriter output_detailed;


Table sizeTable;
Table noteYLocationTable;
Table dieseToggleTable;
int totalPages;
float pageTime;
float firstPageTime;
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
// int[] notes = {21,23,24,26,28,29,31,33,35,36,38,40,41,43,45,47,48,50,52,53,55,57,59,60,62,64,65,66,69,71,72,74,76,77,79,81,83,84,86,88,89,91,93,95,96,98,100,101,103,105,107,108};
// int[] dieseNotes = {22,25,27,30,32,34,37,39,42,44,46,49,51,54,56,58,61,63,66,68,70,73,75,78,80,82,85,87,90,92,94,97,99,102,104,106};
float noteWidth = 4*staffGap;
float noteHeight = 4*staffGap;
// JSONObject noteFiles ={0.008:"note-128.svg",0.016:"note-64.svg",0.032:"note-32.svg",0.064:"note-16.svg",0.128:"note-8.svg",0.256:"note-4.svg",0.512:"note-2.svg",1.024:"note-1.svg"};
PShape clef;

PGraphics svg;
PGraphics svgControl;


float measuresPerStaff = 6;
float tempo = 234; //quarter notes per minute
float measureTime = (60/tempo)*2; //seconds
float staffTime = measureTime*measuresPerStaff;


void setup() {
size(900, 1200);
sizeTable = loadTable("notes_data.csv", "header");
noteYLocationTable = loadTable("note_locations.csv", "header");
// output = createWriter("notes_status.txt");
// output_detailed = createWriter("notes_status_detailed.txt");
json = loadJSONObject("bread_scene2.json");
printSvgSizes();
drawSheetMusic();
}




void drawMeasureBorders(PGraphics graphics, int pageNumber){
		int numberOfStaffsPerThisPage;
	if (pageNumber ==0){
		numberOfStaffsPerThisPage = numberOfStaffsPerPage - 2;
	}else{
		numberOfStaffsPerThisPage = numberOfStaffsPerPage;

	}
	for (int i=0; i<numberOfStaffsPerThisPage; i++){
		for (int j=0; j<measuresPerStaff; j++){
			float x = borderMargin+staffHeight+(j+1)*(staffWidth-staffHeight)/6;
			float y;
			if (pageNumber == 0){
				y =borderMargin+(2+i)*(staffHeight+spaceBetweenStaffs);
			}
			else{
				y =borderMargin+i*(staffHeight+spaceBetweenStaffs);
			}
			graphics.line(x,y,x,y+staffHeight);
		}
	}
}

void drawStaffLines(PGraphics graphics,int staffGp, int LocY){
	for (int i=0; i<5; i++){
		int y = i*staffGp+LocY;
		graphics.line(borderMargin, borderMargin+y, width-borderMargin, borderMargin+y);
	}
}
void drawStaffs(PGraphics graphics, int pageNumber){
	int numberOfStaffsPerThisPage;

	if (pageNumber ==0){
		numberOfStaffsPerThisPage = numberOfStaffsPerPage - 2;
	}else{
		numberOfStaffsPerThisPage = numberOfStaffsPerPage;

	}
	for (int i=0; i<numberOfStaffsPerThisPage; i++){

		int yOfStaff;
		int yOfCleff;
		float startXCleff = -staffGap;
		float startYCleff = -2.3*staffGap;
		if (pageNumber==0){
			yOfStaff = (2+i)*(staffHeight+spaceBetweenStaffs);
			yOfCleff = (2+i)*(staffHeight+spaceBetweenStaffs);
		}else{
			yOfStaff = i*(staffHeight+spaceBetweenStaffs);
			yOfCleff = i*(staffHeight+spaceBetweenStaffs);
		}
		// System.out.println(yOfStaff);
		drawStaffLines(graphics,staffGap, yOfStaff);
		drawClefs(graphics,startXCleff,startYCleff+yOfCleff);
	}
}
void drawClefs(PGraphics graphics,float x, float y){
	clef = loadShape("clef.svg");
	graphics.shape(clef, borderMargin+x, borderMargin+y, 6*staffGap, 8*staffGap);
}
// void isItNote(int midiNote){
//
// }
String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}
void printSvgSizes(){
	String path = sketchPath();
	String[] filenames = listFileNames(path+"/data/notes");
	int i = 1;
	for (String file : filenames){

		if (file.contains(".DS_")){
			continue;
		}
		PShape s = loadShape("notes/"+file);
		println(i+": "+file +"| width: "+s.width+", height: "+s.height);
		i++;
	}
}
String[] whichNote(float duration){
	// for (int i; i < noteFiles)
	String[] fileNames = new String[2];
	if (duration <= 0.008){
		fileNames[0] = "Quintuple-croche_tête_en_bas.svg";
		fileNames[1] = "Quintuple-croche.svg";
	}else if(duration <= 0.016){
		fileNames[0] = "Quadruple-croche_tête_en_bas.svg";
		fileNames[1] = "Quadruple-croche.svg";
	}else if(duration <= 0.024){//.
		fileNames[0] = "Quadruple-croche_pointée_tête_en_bas.svg";
		fileNames[1] = "Quadruple-croche_pointée.svg";
	}else if(duration <= 0.028){//..
		fileNames[0] = "Quadruple-croche_doublement_pointée_tête_en_bas.svg";
		fileNames[1] = "Quadruple-croche_doublement_pointée.svg";
	}else if(duration <= 0.032){
		fileNames[0] = "Triple-croche_tête_en_bas.svg";
		fileNames[1] = "Triple-croche.svg";
	}else if(duration <= 0.048){//.
		fileNames[0] = "Triple-croche_pointée_tête_en_bas.svg";
		fileNames[1] = "Triple-croche_pointée.svg";
	}else if(duration <= 0.056){//..
		fileNames[0] = "Triple-croche_doublement_pointée_tête_en_bas.svg";
		fileNames[1] = "Triple-croche_doublement_pointée.svg";
	}else if(duration <= 0.064){
		fileNames[0] = "Double-croche_tête_en_bas.svg";
		fileNames[1] = "Double-croche.svg";
	}else if(duration <= 0.096){//.
		fileNames[0] = "Double-croche_pointée_tête_en_bas.svg";
		fileNames[1] = "Double-croche_pointée.svg";
	}else if(duration <= 0.112){//..
		fileNames[0] = "Double-croche_doublement_pointée_tête_en_bas.svg";
		fileNames[1] = "Double-croche_doublement_pointée.svg";
	}else if(duration <= 0.128){
		fileNames[0] = "Croche_tête_en_bas.svg";
		fileNames[1] = "Croche.svg";
	}else if(duration <= 0.192){//.
		fileNames[0] = "Croche_pointée_tête_en_bas.svg";
		fileNames[1] = "Croche_pointée.svg";
	}else if(duration <= 0.224){//..
		fileNames[0] = "Croche_doublement_pointée_tête_en_bas.svg";
		fileNames[1] = "Croche_doublement_pointée.svg";
	}else if(duration <= 0.256){
		fileNames[0] = "Noire_tête_en_bas.svg";
		fileNames[1] = "Noire.svg";
	}else if(duration <= 0.384){//.
		fileNames[0] = "Noire_pointée_tête_en_bas.svg";
		fileNames[1] = "Noire_pointée.svg";
	}else if(duration <= 0.448){//..
		fileNames[0] = "Noire_doublement_pointée_tête_en_bas.svg";
		fileNames[1] = "Noire_doublement_pointée.svg";
	}else if(duration <= 0.512){
		fileNames[0] = "Blanche_tête_en_bas.svg";
		fileNames[1] = "Blanche.svg";
	}else if(duration <= 0.768){//.
		fileNames[0] = "Blanche_pointée_tête_en_bas.svg";
		fileNames[1] = "Blanche_pointée.svg";
	}else if(duration <= 0.896){//..
		fileNames[0] = "Blanche_doublement_pointée_tête_en_bas.svg";
		fileNames[1] = "Blanche_doublement_pointée.svg";
	}else if(duration <= 1.024){
		fileNames[0] = "Ronde_tête_en_bas.svg";
		fileNames[1] = "Ronde.svg";
	}else if(duration <= 3.072){//.
		fileNames[0] = "Ronde_pointée_tête_en_bas.svg";
		fileNames[1] = "Ronde_pointée.svg";
	}else{//..
		fileNames[0] = "Ronde_doublement_pointée_tête_en_bas.svg";
		fileNames[1] = "Ronde_doublement_pointée.svg";
	}
	return fileNames;
}
void dieseTableSetup(){
	dieseToggleTable = new Table();

	dieseToggleTable.addColumn("NoteName");
	dieseToggleTable.addColumn("DieseValueTracker");

}
String dieseToggle(TableRow noteInfo){
	//this is where we will keep track whether a note changed state between being sharp or not
	String noteName = noteInfo.getString("noteName");
	noteName = noteName.replace("Diese","");
	// println(noteName);
	String dieseValue = noteInfo.getString("diese");
	String returnValue; //value indicating if the note has changed state or not, if yes to what: all possible values {diese, natural, no}
	TableRow dieseToggleRow = dieseToggleTable.findRow(noteName, "NoteName");
	if (dieseToggleRow == null){
			TableRow newRow = dieseToggleTable.addRow();
		  newRow.setString("NoteName", noteName);
		  newRow.setString("DieseValueTracker", dieseValue);
			if (dieseValue.equals("true")){
				returnValue = "diese";
				// output_detailed.println("added new note: "+noteName+", "+returnValue);

			} else {
				returnValue = "no";
				// output_detailed.println("added new note: "+noteName+", "+returnValue);

			}
	} else {
		// println("yeeeeaasss--------------------");
		String dieseToggleValue =  dieseToggleRow.getString("DieseValueTracker");
		if (dieseToggleValue.equals(dieseValue)){
			returnValue = "no";
			// output_detailed.println("note found: "+noteName+", "+returnValue);
		}else{
			if (dieseValue.equals("true")){
				returnValue = "diese";
				dieseToggleRow.setString("DieseValueTracker", dieseValue);
				// output_detailed.println("note found: "+noteName+", "+returnValue);
			} else {
				returnValue = "natural";
				// output_detailed.println("note found: "+noteName+", "+returnValue);
				dieseToggleRow.setString("DieseValueTracker", dieseValue);

			}
		}
	}
return returnValue;
}
// TODO adjust the location of the note after notes are in the correct size
//TODO return string array for [y,isitdiese]
String[] noteLocationOnStaff(int midiNote){
	// i got midi to note conversion info from the notes.gif file that is in data/ folder of the project
	int baseDo = 60;
	float baseDoY = 5*staffGap;
	float yDiff;
	float y;
	String noteName;
	String diese;
	TableRow resultNoteLocation;
	if(midiNote>=baseDo){
		// println("noteInOctave: "+midiNote+", "+noteInOctave)
		int noteInOctave = (midiNote-baseDo) % 12;
		if (noteInOctave==12){
			noteInOctave = 0;
		}
		int difOctave = (midiNote-baseDo)/12;
		resultNoteLocation = noteYLocationTable.findRow(str(noteInOctave), "noteValue");
		yDiff = resultNoteLocation.getFloat("ynumberofStaffGaps");
		noteName = resultNoteLocation.getString("noteName");
		diese = resultNoteLocation.getString("diese");
		y = baseDoY-difOctave*3.5*staffGap-yDiff*staffGap;
	}
	else{
		int difOctave = (baseDo-midiNote)/12;

		int noteInOctave =12-((baseDo-midiNote) % 12);
		if (noteInOctave==12){
			noteInOctave = 0;
		}
		// println("noteInOctave: "+midiNote+", "+noteInOctave);
		resultNoteLocation = noteYLocationTable.findRow(str(noteInOctave), "noteValue");
		yDiff = 3.5-resultNoteLocation.getFloat("ynumberofStaffGaps");
		noteName = resultNoteLocation.getString("noteName");
		diese = resultNoteLocation.getString("diese");
		y = baseDoY+difOctave*3.5*staffGap+yDiff*staffGap;
	}
	String dieseToggleValue = dieseToggle(resultNoteLocation);
	String[] stuffToReturn = {str(y), noteName, dieseToggleValue};
	return stuffToReturn;
}


	// //TODO: add sharps and return notes to natural
	// for (int i=0; i<notes.length; i++){
	// 	if(midiNote==notes[i]){
	// 		// println("yeees");
	// 		y += (i-f5faIndex)*staffGap/2;
	// 		break;
	// 	}
	// 	else{
	// 		y = -noteHeight/8;
	// 	}
	// 	// if(f5fa == notes[i]){
	// 	// 	println(i);
	// 	// }
	// }
	// // println(midiNote+", "+y);
	// return y;

void drawExtraStaffLines(float noteYonStaff, float y, float x, float anchorPointX){
println("Here is the noteYonStaff: "+str(int(noteYonStaff)));
int amountOfStaff = int(noteYonStaff)/staffGap;
if (amountOfStaff<0){
	for(int i=0; i>amountOfStaff-1; i--){
		svg.line(x-anchorPointX-staffGap/4,(i*staffGap)+y,x+2*staffGap/3,(i*staffGap)+y);
	}
}else if(amountOfStaff>0){
	println("Here is the amountofStaff: "+str(amountOfStaff));

	for(int i=0; i<amountOfStaff+1; i++){
		svg.line(x-anchorPointX-staffGap/4,(i*staffGap)+y,x+2*staffGap/3,(i*staffGap)+y);
	}
}

}
void drawNotes(JSONObject note, int pageNumber){
	// println();
// Unravel JSON data into variables
	String name = note.getString("name");
	int midi = note.getInt("midi");
	float firstTime = note.getFloat("time");
	float velocity = note.getFloat("velocity");
	float duration = note.getFloat("duration");
	// println(time);
	//amount of time 1 page takes to play
	float pageTime = numberOfStaffsPerPage*staffTime;
	// int pageNumber = 1+int(time/pageTime);
	// println(time+", "+pageTime);
	//let's print only first page for now
	// if(firstTime<=firstPageTime){
	// 	println("------------------------------------------------------------------------------");
	// 	println(firstTime);
	// 	// println(pageTime);
	// 	pageTime = firstPageTime;
	// 	println(pageTime);
	//
	// }else{
	// 	firstTime = firstTime-firstPageTime;
	// 	pageNumber=pageNumber-1;
	// }
	firstTime = 2*staffTime+firstTime;
	if((firstTime<=pageTime*(pageNumber+1))&&(firstTime>pageTime*(pageNumber))){
		// if(pageNumber==0){
		println(firstTime);
		float	time = firstTime % pageTime;
		// }

		// float m = map(time, 0, 100, 0, width);
		// println(time);
		int staffNo = int(time/staffTime)+1;
		// if(firstTime<firstPageTime){
		// 	staffNo = staffNo+2;
		// }
		// println(time+", staffno: "+staffNo);
		float y = (staffNo-1)*(staffHeight+spaceBetweenStaffs)+borderMargin;
		String[] noteData = noteLocationOnStaff(midi);
		float noteYonStaff = float(noteData[0]);
		String noteName = noteData[1];
		String dieseToggleValue = noteData[2];
		println(dieseToggleValue);
		float finalY = noteYonStaff +y;
		float x = map(time-(staffNo-1)*staffTime, 0, staffTime, borderMargin+staffHeight, width-borderMargin-4*staffGap);
		drawMeasureBorders(svg,pageNumber);
		String[] notefiles = whichNote(duration);
		String filename;
		float sizeRatio;
		float anchorRatioX;
		float anchorRatioY;
		if(noteYonStaff>staffHeight/2){
			filename = notefiles[0];
		}else{
			filename = notefiles[1];
		}
		TableRow result = sizeTable.findRow(filename, "fileName");
		sizeRatio = result.getFloat("sizeRatio");
		anchorRatioX = result.getFloat("anchorRatioX");
		anchorRatioY = result.getFloat("anchorRatioY");
		PShape noteSvg = loadShape("notes/"+filename);
		PShape dieseSVG = loadShape("notes/Dièse.svg");
		PShape naturalSVG = loadShape("notes/Becarre.svg");
		float finalWidthDiese = 3*dieseSVG.width*0.72;
		float finalHeightDiese = 3*dieseSVG.height*0.72;
		float anchorPointXDiese = finalWidthDiese*0.5;
		float anchorPointYDiese = finalHeightDiese*0.5;
		float finalWidthNatural = 3*naturalSVG.width*0.72;
		float finalHeightNatural = 3*naturalSVG.height*0.72;
		float anchorPointXNatural = finalWidthNatural*0.5;
		float anchorPointYNatural = finalHeightNatural*0.5;
		float finalWidth = 3*noteSvg.width*sizeRatio;
		float finalHeight = 3*noteSvg.height*sizeRatio;
		float anchorPointX = finalWidth*anchorRatioX;
		float anchorPointY = finalHeight*anchorRatioY;
		// for (int i=0; i<finalY)
		drawExtraStaffLines(noteYonStaff,y,x,anchorPointX);

		svg.shape(noteSvg, x-anchorPointX, finalY-anchorPointY, finalWidth, finalHeight);
		if (dieseToggleValue.equals("diese")){
				svg.shape(dieseSVG, x-anchorPointXDiese-1.5*staffGap, finalY-anchorPointYDiese, finalWidthDiese, finalHeightDiese);
		}else if(dieseToggleValue.equals("natural")){
				svg.shape(naturalSVG, x-anchorPointXNatural-1.5*staffGap, finalY-anchorPointYNatural, finalWidthNatural, finalHeightNatural);
		}
		//Uncomment for printing the note names for control
		// if(staffNo==1){
		// 		svg.fill(50);
		// }else if(staffNo==2){
		// 		svg.fill(#2FF3E0);
		// }else if(staffNo==3){
		// 		svg.fill(#F8D210);
		// }else if(staffNo==4){
		// 		svg.fill(#FA26A0);
		// }else if(staffNo==5){
		// 		svg.fill(#F51720);
		// }else{
		// 		svg.fill(50);
		// 	}
		// svg.textSize(15);
		// svg.text(noteName, x-4, finalY);
		// output.println(noteName+", "+dieseToggleValue);

	}

}
void drawPageNo(int pageNumber){
	pageNumber = pageNumber+1;
	float pageNoX;
	float pageNoY;

		if(pageNumber % 2 == 0){
			pageNoX = staffHeight;
			pageNoY = staffHeight;
		}else{
			pageNoX = width - staffHeight-40;
			pageNoY = staffHeight;
		}
		svg.fill(50);
		svg.textSize(40);
		svg.text(pageNumber, pageNoX, pageNoY+40);

}
void drawSheetMusic(){
	dieseTableSetup();

	JSONArray tracks = json.getJSONArray("tracks");
	JSONObject track1 = tracks.getJSONObject(0);
	JSONArray notes = track1.getJSONArray("notes");
	float fullDuration = json.getFloat("duration");
	println(fullDuration);
 	pageTime= numberOfStaffsPerPage*staffTime;
	firstPageTime= (numberOfStaffsPerPage-2)*staffTime;
	totalPages = 2+int(fullDuration/pageTime);
	for (int pageNo = 0; pageNo<totalPages; pageNo++){
		println("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
		println(pageNo);
		svg = createGraphics(width, height, PDF, "output"+str(pageNo)+".pdf");
		svg.beginDraw();
		svg.background(255,255,255);
		drawStaffs(svg, pageNo);
		if (pageNo>0){
			drawPageNo(pageNo);
		}
		for (int i = 0; i < notes.size(); i++) {
				JSONObject note = notes.getJSONObject(i);
				drawNotes(note, pageNo);
			}
		svg.dispose();
		svg.endDraw();
	}

	// output.flush(); // Writes the remaining data to the file
  // output.close();
	// output_detailed.flush(); // Writes the remaining data to the file
	// output_detailed.close();
	// PShape finalDrawing = loadShape("output.pdf");
	// shape(finalDrawing,0,0,900,1200);


}


// Sketch prints:
// 0, Panthera leo, Lion
// void draw() {
//   image(svg, 0, 0);
// }
