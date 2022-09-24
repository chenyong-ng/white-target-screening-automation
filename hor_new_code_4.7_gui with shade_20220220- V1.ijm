var screennum=0;
var screenpassed=0;
var yield=0;
var txtWindowtitle = "[Progress]";
var del_grid_image = 1;
var calc_calbrifactor = 1;
var mtssFileprefix = "Imagex1BkgTest_S01_C001_T1_P0001"; 
//var mtssFileprefix = "Imagex1BkgTest_S01_T1_B3"
macro "white screen uniformity check" {
	//setBatchMode(true)     			//run image in background
		 
#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Golden Sample directory", style = "directory") gs_input
#@ String (choices={"backend", "MTSS"}, style="radioButtonHorizontal") imagestype
#@ String (choices={"screen outcome", "full detailed results"}, style="radioButtonHorizontal") resultchoice
#@ String (label = "File suffix", value = ".tiff") suffix
	start = getTime();
	n=0;
	//screenpassed=0;
	//screennumber=0;
	//yield=0;
	run("Clear Results");//clear results window.
	print("\\Clear"); //clear log window
	print(screenWidth, screenHeight);
	if (isOpen("Log")) {
		selectWindow("Log");
		setLocation(screenWidth*7/10, 80);
	}

	print(indexOf(toUpperCase(input), toUpperCase("backend")));
	print(indexOf(toUpperCase(input), "MTSS"));
	if ( indexOf(toUpperCase(input), toUpperCase("backend"))>0 && imagestype == "MTSS")
	{
		exit("error: please check imagestype selection (backend?)");
	}
	else
	{
		if ( indexOf(toUpperCase(input), "MTSS")>0 && imagestype == "backend")
		{
			exit("error: please check imagestype selection (MTSS?)");
		}
		else {
			if (indexOf(toUpperCase(input), toUpperCase("backend"))<0 && indexOf(toUpperCase(input), "MTSS")<0 )
			{exit("error: please correct fold name according to conventions in manual");}
		}
			
	}
	
	run("Text Window...", "name="+ txtWindowtitle +" width=25 height=2 monospaced");
	if (isOpen("Progress")) {
		selectWindow("Progress");
		setLocation(screenWidth*7/10, 20);
	}
	processFolder(input);
	//print("\\Clear"); //clear log window
	print(txtWindowtitle, "\\Close");
	
	print("input directory is: " + input);
	print("images type is: " + imagestype);	
	print("Total time used (s)", (getTime()-start)/1000);   
	wait(1500);
	if (isOpen("Log")) {
		selectWindow("Log");
		run("Close" );
    }
    wait(100);
    if (isOpen("Results")) {
         //selectWindow("Results"); 
         //run("Close" );
    }
}//macro ends

/****************functions module******************/
// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	
	list = getFileList(input);
	//Array.show(list); //subfolder (e.g. N001~N100)lists;// exit;
	list = Array.sort(list);
	postionoutcomearray= newArray();screennumberarray=newArray();positionnumberarray=newArray();
	foldernamearray=newArray();calibrationfactorarray=newArray();
	numofpassedpositions= 0;
	
	/*****************************************************************************
	 * transverse all images subfolders (N001~N999) to check validity of folders
	 * extract screen info: screenname, positionno, channelno
	 * check validity of images filename 
	 *****************************************************************************/
	 
	for (i = 0; i < list.length; i++) 
	{
		print("------------------start 1st processing "+(i+1)+"th folder: "+list[i]+"------------------");
		if (!File.isDirectory(input + File.separator + list[i])) {
			exit("Caution: please check there shouldn't be any files in folder: " + input);
		}
		else if(File.isDirectory(input + File.separator + list[i]))
		{
			//processsubFolder(input + File.separator + list[i]+File.separator+ list[i]);
			screennum++;
			list2 = getFileList(input + File.separator + list[i]);
			list2 = Array.sort(list2);
			/*Array.show("Arrays (row numbers)", list, list2); //list-subfolder (e.g. N001~N100)lists
			exit;*/
			if(list2.length == 0)
			{
				exit("Caution: Subfolder is empty."+"---"+list[i]);
			}

			positionoutcomearray2 = newArray();
			numofpassedpositions2 = 0;
			//screenpassed2=0;
			if(imagestype == "backend")
			{	
				folderscreenname= substring(list[i], 0, 4); //backend folderscreenname M015/, mtss folderscreenname= M086 P3-2462619030003_BkgTestx1Prescan_0849_14Apr2020_
				//folderscreenname= list[i];
				print("folder_screen_name: "+folderscreenname);
				foldernamearray = Array.concat(foldernamearray,folderscreenname);//maximum M999
				if( i>0 ) {
					if (foldernamearray[i]==foldernamearray[i-1]) //[0]
					exit("Caution: Duplicate file name subfolder present: " +list[i]); //possibly in MTSS folder or N001,N0012
				}
				backendchannelnumberarray = newArray();	

				for (k = 0; k < list2.length; k++) 
				{
					if( endsWith(list2[k], suffix) )//
					{
						print("image file:" +list2[k]);
						list2klen=lengthOf(list2[k]);
						print("image file name length: " +list2klen);
						
						//backendfilename = 2462619030003_J016_imagex1P1_S01_T1_B3_M3_X3_E750_A0_G55.tiff False False
						if (list2klen< 55 )
						{
							exit("Caution: Backend imagetype selected instead of MTSS.");
						}
						
						filescreennumber=substring(list2[k], 14, 18);
						print("file_screen_number: "+filescreennumber);						
						screennumberarray=Array.concat(screennumberarray,filescreennumber);
						filepositionnumber=substring(list2[k], 26, 28);
						print("file_position_number: "+filepositionnumber);
						positionnumberarray=Array.concat(positionnumberarray,filepositionnumber);
						screennumbersimilaroutcome=1;
						filechannelnumber=substring(list2[k], 39, 44);
						print("file_channel_number: "+filechannelnumber);
						backendchannelnumberarray=Array.concat(backendchannelnumberarray,filechannelnumber);

						if ((k!=0) && (k-2)%3==0)
						{
							positionnumbersimilaroutcome=1;
							for (t = 1; t < 3; t++) 
							{
								if(positionnumberarray[t]==positionnumberarray[0])
								{
									positionnumbersimilaroutcome*=1;
								}
								else
								{
									positionnumbersimilaroutcome*=0;
									exit("Caution: Image file's position name different from other 2 channels' images of similar position.");
								}
							}
							positionnumberarray=newArray();

							if(backendchannelnumberarray[0]==backendchannelnumberarray[1] || backendchannelnumberarray[0]==backendchannelnumberarray[2]||backendchannelnumberarray[1]==backendchannelnumberarray[2])
							{
								exit("Caution: Duplicate channel number MTSS image.");
							}
							for (t = 0; t < 3; t++) 
							{
								if(backendchannelnumberarray[t]!="M1_X1" && backendchannelnumberarray[t]!= "M2_X2" && backendchannelnumberarray[t]!="M3_X3")
								{
									exit("Caution: Additional channel/unncessary channel image for backend present");
								}
							}

							backendchannelnumberarray=newArray();			
					    }
					    
						if(screennumberarray[k]==screennumberarray[0])
						{
							screennumbersimilaroutcome*=1;
						}
						else
						{
							screennumbersimilaroutcome*=0;
							exit("Caution: Image file's screen number different from that of other channels' images in same folder.");
						}
					}
				}//for k loop
				screennumbersimilaroutcome=1;
				if(screennumberarray[0] != folderscreenname)
				{
					exit("Caution: Image files' screen number different from subfolder filename. "+list[i]);
				}
				
				screennumberarray=newArray();
					
			}

			else if(imagestype=="MTSS")
			{	
				//mtss file name = Imagex1BkgTest_S01_T1_B3_M2_X2_E831_A0_G55
				channelnumberarray=newArray();mtsscount=0;mtssimagecount=0;
				for (k = 0; k < list2.length; k++) 
				{
					if(endsWith(list2[k], suffix))//
					{
						if(startsWith(list2[k], mtssFileprefix))
						{
							mtssimagecount++;
						}
						
						if(startsWith(list2[k], mtssFileprefix))
						{
							//channelnumber=substring(list2[k], 33, 38); //25, 30
							print(indexOf(list2[k], "_M")+1, indexOf(list2[k], "_X")+3);
							channelnumber = substring(list2[k], indexOf(list2[k], "_M")+1, indexOf(list2[k], "_X")+3);
						
							if(channelnumber == "M1_X1" || channelnumber == "M2_X2" || channelnumber == "M3_X3")
							{
								channelnumberarray=Array.concat(channelnumberarray,channelnumber);
								mtsscount++;
							}
							
							if (mtsscount==3)
							{
								k=200;
							}		
						}
						
					}
				}//for k loop	
				if(mtssimagecount==0)
				{
					exit("Caution: MTSS imagetype option selected instead of Backend.");
				}
				
				if(mtsscount<3)
				{
					exit("Caution: Less than 3 MTSS images of binning 3 found");
				}

				print("channelnumberarray:");
				Array.print(channelnumberarray);
				
				channelnumberarraylen=lengthOf(channelnumberarray);
				for (k = 0; k < channelnumberarraylen; k++) 
				{
					if(channelnumberarray[k]==channelnumberarray[0] && k!=0)
					{
						exit("Caution: Duplicate channel number MTSS image.");
					}
					if(channelnumberarray[k]==channelnumberarray[1] && k!=1)
					{
						exit("Caution: Duplicate channel number MTSS image.");
					}
					if(channelnumberarray[k]!="M1_X1" && channelnumberarray[k]!= "M2_X2" && channelnumberarray[k]!="M3_X3")
					{
						exit("Caution: Additional channel/unncessary channel image for MTSS present");
					}

				}			
			}

		}
		else if(endsWith(list[i], suffix)) //can be removed because 1st if
		{	exit("Caution:Images files not in screen-number subfolders, or main folder not selected as input folder.");		}
	}//for i loop
	
	if(screennum != list.length) {
	print("screennum!=list.length ", screennum, list.length); exit;}
	print("total number of screens: ", screennum);
	/*Array.show("Arrays (row numbers)",list,list2,foldernamearray,screennumberarray,positionnumberarray); //subfolder (e.g. N001~N100)lists
	exit;*/

	/*****************************************************************************
	 * uniformity_check
	 * get array
	 *****************************************************************************/

	for (i = 0; i < list.length; i++) 
	{
		print("------------------start 2nd processing "+(i+1)+"th folder: "+list[i]+"------------------");
		if(File.isDirectory(input + File.separator + list[i]))
		{
			list2 = getFileList(input + File.separator + list[i]);
			list2 = Array.sort(list2);
			numofpassedpositions2=0;	
			positionoutcomearray2= newArray(); mtsscount2=0;
				
			for (k = 0; k < list2.length; k++) 
			{	
				if(endsWith(list2[k], suffix))//
				{		
					if(imagestype=="backend")
					{		
						setResult("Foldername",nResults, list[i]);
						print(k+1, "-th file started----------------------------------------------");
						positionoutcomearray2 = Array.concat(positionoutcomearray2,uniformity_check(input + File.separator + list[i], list2[k]));
						print(k+1, "-th file ended------------------------------------------------");
						//Array.show("Arrays (row numbers)",list,list2,positionoutcomearray2);
						//exit;
						if ((k!=0) && (k-2)%3==0) //process every position * three images
						{
							positionoutcomelen2 = lengthOf(positionoutcomearray2);
							/*if (outcomelen==1)
							{overall=outcomearray[0];}
							else{ */
							overall=0;
							for (m=0; m < positionoutcomelen2; m++)
							{
								overall+= positionoutcomearray2[m];
							}
							overall=overall/3;
							if(overall>=48)
							{									
								setResult("Overall Screen Position Pass/Fail", nResults-1, "Overall Screen Position Pass-"+overall);
								numofpassedpositions2++;
									
							}
							else 
							{	setResult("Overall Screen Position Pass/Fail", nResults-1, "Overall Screen Position Fail"); }
				
							positionoutcomearray2=newArray();
							//processFile(input, input, list[i]);
						}

					}// if backend					
					else if(imagestype == "mtss") //MTSS; no check of duplicate screens now
					{	//print(imagestype+"---line 349");
						//exit;				
						if(startsWith(list2[k], mtssFileprefix))
						{
							print(indexOf(list2[k], "_M")+1, indexOf(list2[k], "_X")+3);
							channelnumber = substring(list2[k], indexOf(list2[k], "_M")+1, indexOf(list2[k], "_X")+3);

							print(channelnumber); //exit;
							if(channelnumber == "M1_X1" || channelnumber == "M2_X2" || channelnumber == "M3_X3")
							{
								setResult("Foldername",nResults, list[i]);
								setResult("ChannelNo",nResults-1, channelnumber);
								print(k, "-th MTSS file started----------------------------------------------");
								print(list2[k]);
								positionoutcomearray2= Array.concat(positionoutcomearray2,uniformity_check(input + File.separator + list[i], list2[k]));
								print("positionoutcomearray2:");
								Array.print(positionoutcomearray2);
								print(k, "-th MTSS file ended------------------------------------------------");
								mtsscount2++;
							}							

							if ((mtsscount2!=0) && (mtsscount2%3==0))//process three channels only. no position
							{
								positionoutcomelen2 = lengthOf(positionoutcomearray2);
								/*if (outcomelen==1)
								{overall=outcomearray[0];}
								else{ */
								overall=0;
								for (m=0; m < positionoutcomelen2; m++)
								{
									overall+= positionoutcomearray2[m];
								}
								overall=overall/3;
								//Array.getStatistics(positionoutcomearray2, min, max, mean, stdDev);
								//print(mean,overall);
								if(overall>=48)
								{									
									setResult("Overall Screen Position Pass/Fail", nResults-1, "Overall Screen Position Pass-"+overall);
									numofpassedpositions2++;
										
								}
								else
								{	setResult("Overall Screen Position Pass/Fail", nResults-1, "Overall Screen Position Fail");}
					
								positionoutcomearray2=newArray();
								k=400; //jump out of k loop
								//exit;
								//processFile(input, input, list[i]);
							}//if
							
						}//if
						
					}// if MTSS
		
				}// if suffix
				
			}//for k loop
			
			if(numofpassedpositions2>=1)	
			{									
				setResult("Overall Screen Pass/Fail", nResults, "Overall Screen Pass");
				screenpassed++ ;
			}
			else{
				setResult("Overall Screen Pass/Fail", nResults, "Overall Screen Fail");
			}
			
			if(imagestype=="MTSS" && calc_calbrifactor)
			{	
				folderscreenpositionname= substring(list[i], 0, 7)  ;
				//print(folderscreenpositionname);
				//comment to avoid calibrationfactor calculate
				//print("gs_input", gs_input); exit;
				calibrationfactorarray= Array.concat(calibrationfactorarray,calibrationfactor(input + File.separator + list[i], gs_input,folderscreenpositionname ));
			
			}
					
		}//if
		//print(i+"/"+screennum+" ("+(i*100)/screennum+"%)\n"+getBar(i, screennum));
		print(txtWindowtitle, "\\Update:"+(i+1)+"/"+screennum+" ("+((i+1)*100)/screennum+"%)\n"+getBar(i, screennum));
		//wait(200);
		//exit;
	}//for i loop	
		
	yieldratio= (screenpassed/screennum)*100;
	print("yieldratio,screenpassed,screennum");
	print(yieldratio+"%",screenpassed,screennum);
	//waitForUser;
	setResult("Number of screens tested", nResults, screennum);
	setResult("Screen yield%", nResults-1, yieldratio);
	if (imagestype == "backend" )
	{
		run("Read and Write Excel","stack_results sheet=[backend]");   //https://www.youtube.com/watch?v=dLkoB25MTIY
	} else {
		run("Read and Write Excel","stack_results sheet=[MTSS]");
	}
} //function processFolder(input) 
	

// function works perfectly now but have been integrated into processfolder function.
function findyield(screennum,screenpassed) //not used
{
	yield= (screenpassed/screennum)*100;
	print(yield,screenpassed,screennum);
	waitForUser;
	setResult("Screen yield%", nResults-1, yield);
}

function calibrationfactor(input, gs_input, screenname)
{
	setBatchMode(true);  

	//--------------------- golden sample ----------------------//
	//GSdir = "C:/WST_7A_2462620040492_BkgTestx1Prescan_1209_20Apr2020/" ;  
	GSdir = gs_input;
	GSName = substring(GSdir, indexOf(GSdir,"\\")+1, indexOf(GSdir,"_")); //"WST7A";
	print("GSdir: ", GSdir);
	print("golden screen name: ", GSName);

	griddedexcels = newArray();
	griddedexcels = Array.concat("m1x1", "m2x2", 
								 "m2x7_Trans", "m3x3", 
								 "m4x4", "m5x6");

	GS_max = newArray();

	//for every gridded excel of the golden sample
	for (i=0; i<6; i++)
	{
		path1 = GSdir + File.separator + griddedexcels[i] + "_gridded.csv";
		print (path1);
		if (!File.exists(path1)) {
			exit("Caution: no such file exits, please check! "+ path1)
		}
		run("Text Image... ", "open=[path1]");
		
		//read values of pixels from 4x3 grid
		GS_index_1 = getPixel(11,8);
		GS_index_2 = getPixel(12,8);
		GS_index_3 = getPixel(13,8);
		GS_index_4 = getPixel(11,9);
		GS_index_5 = getPixel(12,9);
		GS_index_6 = getPixel(13,9);
		GS_index_7 = getPixel(11,10);
		GS_index_8 = getPixel(12,10);
		GS_index_9 = getPixel(13,10);
		GS_index_10 = getPixel(11,11);
		GS_index_11 = getPixel(12,11);
		GS_index_12 = getPixel(13,11);
		
		GS_grid = newArray();

		GS_grid = Array.concat(GS_index_1, GS_index_2, GS_index_3, 
							   GS_index_4, GS_index_5, GS_index_6, 
							   GS_index_7, GS_index_8, GS_index_9, 
							   GS_index_10, GS_index_11, GS_index_12);

		//obtain max value from the 4x3 grid
		Array.getStatistics(GS_grid, min, max, mean, stdDev);

		//keep max values for all channels in an array
		GS_max = Array.concat(GS_max, max);
		
		//print (GSName + " " + griddedexcels[i] + " max value: " + max);
		
		close();
	}

	//--------------------- new white screens ----------------------//

	//for 1 white screen
	nWSdir = input;
	nWS_savedir = nWSdir;

	ScreenName = screenname;
	newfilelist = newArray();
	//save all 6 gridded excel files in another folder
	for (i=0; i<6; i++)
	{	
		path1 = nWSdir + File.separator + griddedexcels[i] + "_gridded.csv";
		print (File.exists(path1));
		if (!File.exists(path1)) {
			exit("Caution: no such file exits, please check! "+ path1)
		}
		run("Text Image... ", "open=[path1]");
							 
		
		newname = "griddedabc_" + ScreenName + "_" + griddedexcels[i];
		saveAs("tiff", nWS_savedir + "/" + newname);
		newfilelist = Array.concat(newfilelist, newname+".tif");
		close();
	}

	list = getFileList(nWS_savedir); listnew = newArray();
	//print("renamed file sequence: ");
		
	for (k = 0; k < list.length; k++){
		if(startsWith(list[k], "griddedabc_"))
		{
			listnew = Array.concat(listnew, list[k]);
		}
	}
	//Array.show(list,listnew,newfilelist);
	nWS_max = newArray();

	//analyze white screen for each channel
	for (i=0; i<6; i++)
	{
		open(nWS_savedir + "/" + listnew[i]);
		
		nWS_index_1 = getPixel(11,8);
		nWS_index_2 = getPixel(12,8);
		nWS_index_3 = getPixel(13,8);
		nWS_index_4 = getPixel(11,9);
		nWS_index_5 = getPixel(12,9);
		nWS_index_6 = getPixel(13,9);
		nWS_index_7 = getPixel(11,10);
		nWS_index_8 = getPixel(12,10);
		nWS_index_9 = getPixel(13,10);
		nWS_index_10 = getPixel(11,11);
		nWS_index_11 = getPixel(12,11);
		nWS_index_12 = getPixel(13,11);

		nWS_grid = newArray();
		
		nWS_grid = Array.concat(nWS_index_1, nWS_index_2, nWS_index_3, 
								nWS_index_4, nWS_index_5, nWS_index_6, 
								nWS_index_7, nWS_index_8, nWS_index_9, 
								nWS_index_10, nWS_index_11, nWS_index_12);
		
		Array.getStatistics(nWS_grid, min, max, mean, stdDev);
		close();
		
		//print(ScreenName + " " + griddedexcels[i] + " max value: " + max);

		nWS_max = Array.concat(nWS_max, max);

		//setResult("Golden Sample Channel", nResults, griddedexcels[i]);
		//setResult("Golden Sample Channel max", nResults-1, GS_max[i]);
		
		setResult("Golden Sample used", nResults, GSName);
		setResult("Screen Name", nResults-1, ScreenName);
		setResult("Channel", nResults-1, griddedexcels[i]);
		
		//setResult("Channel", nResults-1, channel);

		factor = (GS_max[i] / nWS_max[i]);
		print("factor: ", factor, GS_max[i], nWS_max[i]);
		
		//Calibration_factor = Array.concat(Calibration_factor, factor);
		//print("Calibration factor for " + griddedexcels[i] +": " + factor);
		
		setResult("Calibration Factor", nResults-1, factor);
		//setResult("GS_max", nResults-1, GS_max[i]);
		//setResult("nWS_max", nResults-1, nWS_max[i]);
	}
	//Array.show(GS_max, nWS_max);
	return factor;

}


function uniformity_check(input, file)
{ 	//row 686-2236
	numberofcontourlines    = 20;
	speckleheight           = 10000;
	wrinkle_criteria        = 2400;
	deformity_criteria      = 106;
	shadecriteria           = 210; //250 280
	shadeinterval           = 4; //3

	if(imagestype == "backend")
	{
		deformity_criteria  = 81; //76 backend use shorter exposure time
	}
	
	while (nImages>0)
	{
		close();		//close any active images/plots. 
	}
	
	//image preparation
	path1 = input + File.separator + file;//File.openDialog("Choose the image file for analysis");	
	// just taking centre of image and comparing left with right.
	dir = File.getParent(path1);
	filename = File.getName(path1);
	print("Path:", path1);
	print("Name:", filename);
	print("Directory:", dir);
	//waitForUser;	
	open(path1);
	Img1Height = getHeight(); //901
	Img1Width = getWidth();   //1127
	aspectratio = 1; //(Img1Width-60)/(Img1Height-60);  
	BorderWidth = 30;//1127-30*2=1067
	BorderHeight = 30;//901-30*2=841

	//print("img height", Img1Height, "img width", Img1Width);

	GridHeight = 10;
	GridWidth = (aspectratio*GridHeight);
	
	imgGridHeight = floor((Img1Height - 2 * BorderHeight)/GridHeight)+1; // NumGridHeight =84+1=85
	imgGridWidth = floor((Img1Width - 2 * BorderWidth)/GridWidth)+1; //NumGridWidth =106+1=107
	print(imgGridHeight, imgGridWidth);	
	print("aspect ratio", aspectratio);

	hSymmetryRatio  = newArray(); //ratio array of horizontal symmetry
	vSymmetryRatio = newArray(); //ratio array of vertical symmetry
	imgGridWidth  = Img1Width - 2*BorderWidth;
	imgGridHeight = Img1Height- 2*BorderHeight;
	makeRectangle(BorderWidth, BorderHeight, imgGridWidth, imgGridHeight);
	run("Crop");
	Img1Height = getHeight(); //901-60=841
	Img1Width = getWidth();	 //1127-60=1067
	getStatistics(area, croppedImageMean);
	makeRectangle(Img1Width/2-GridWidth, Img1Height/2-GridHeight, GridWidth*GridHeight, GridWidth*GridHeight);
	getStatistics(area, grid100ImageMean);

	if (Img1Width%2 == 1){
		horcenterpoint = floor(Img1Width/2); //even odd number
		horRstartpoint= horcenterpoint+1;
	}
	else{
		horcenterpoint = (imgGridWidth/2);  //even number potential bug for incorrect starting pixel to form grid from
		horRstartpoint= horcenterpoint;
	}
	if (Img1Height%2 == 1){
		vercenterpoint = floor(Img1Height/2); //even odd number
		verDstartpoint= vercenterpoint+1;
	}
	else{
		vercenterpoint = (Img1Height/2);
		verDstartpoint= vercenterpoint;			
	}
	print("horcenterpoint-", horcenterpoint, "vercenterpoint-", vercenterpoint); 
	//exit;
	hspeckleno = 0;
	brightpixel = 0;
	darkspot = 0;
	hSymmetryRatio = newArray();
	hSymmetryRatio1 = newArray();
	hSymmetryRatio2 = newArray();
	vSymmetryRatio = newArray();
	vSymmetryRatio1 = newArray();
	vSymmetryRatio2 = newArray();
	
	/******************************************************************
	 * forming gridded image starts
	 * speckle checking module
	 ******************************************************************/
if(1){
	/**********************fourth quadrant***************************/
	
	ii4 = 0; GridArray_q4 = newArray();
	for (i = verDstartpoint; i < Img1Height; i += GridHeight)	//row
	{	
		rBin = GridHeight; cBin = GridWidth;
		rstart = verDstartpoint + ii4*GridHeight;
		if (rstart != i) {print(rstart, i); waitForUser;}
		rend = verDstartpoint + (ii4+1)*GridHeight - 1;
		if (rend > Img1Height-1)
		{
			rend = Img1Height-1;
			rBin = rend - rstart + 1;
		}
		
		ii4 = ii4+1; jj4 = 0;
		for (j= horRstartpoint; j < Img1Width; j += GridWidth) //col
		{
			//cBin = GridWidth;
			cstart = horRstartpoint + jj4*GridWidth;
			if (cstart != j) {print(cstart, j); waitForUser;}
			cend = horRstartpoint + (jj4+1)*GridWidth;
			if (cend > Img1Width-1)
			{
				cend = Img1Width-1;
				cBin = cend - cstart + 1;
			}
			makeRectangle(cstart, rstart, cBin, rBin);
			getStatistics(area, mean, min, max, std);
			//print("mean--", mean, "max--", max);
			if (max-mean > speckleheight)//there is speckle
			{	hspeckleno++; 
				print("mean--", mean, "min--", min, "max--", max);
				wsRatio = max/ mean; print("white spot ratio:",wsRatio);
				if (wsRatio > 1) 
				{brightpixel++;} print("speckle location: row-", i+BorderWidth, "col-", j+BorderHeight);
			}
			else
			{
				if (ii4 < 3 && jj4 < 4)				
				{bkg=grid100ImageMean;}
				else
				{bkg= croppedImageMean;}
				if (mean - bkg > speckleheight) //grid area smaller that speckle grid100ImageMean
				{
					hspeckleno++; 
					print("mean--", mean, "min--", min, "max--", max, "grid100ImageMean", grid100ImageMean, "speckleheight", speckleheight);
					wsRatio = max/bkg; print("white spot ratio:",wsRatio);
					if (wsRatio>1)
					{brightpixel++;} print("speckle location: row-", i+BorderWidth, "col-", j+BorderHeight);
					//mean = GridArray_q4[0]; //GridArray_q2[GridArray_q2.length-1] //Array.getStatistics(array, min, max, mean, stdDev) 
				}
			}
			GridArray_q4 = Array.concat(GridArray_q4, mean);//4th quadrant
			jj4 = jj4+1;
			if (max-mean > speckleheight || mean - bkg > speckleheight) //if it is not a speckle, then run dark spot
			{};
			else{
			makeRectangle(cstart, rstart, cBin, rBin);
			getStatistics(area, mean, min, max, std);
			//print("mean--", mean, "max--", max);
			if (mean-min > speckleheight)//there is particle or dark spot
			{	
				print("mean--", mean, "min--", min, "max--", max);
				dsRatio = max/mean; print("dark spot ratio:",dsRatio);
			if (dsRatio > 1)
			{darkspot++;} print("darkspot location: row-", i+BorderWidth, "col-", j+BorderHeight);
		}
	}
		}
	}
	print("row:ii4--", ii4, "col:jj4---", jj4);
	
	/**********************first quadrant***************************/
	
	ii1 = 0; GridArray_q1 = newArray();
	for (i = vercenterpoint-GridHeight; i >-GridHeight; i -= GridHeight)	//row
	{
		rBin = GridHeight; cBin = GridWidth;
		rstart = vercenterpoint-GridHeight - ii1*GridHeight;//== i
		if (rstart != i) {print(rstart, i); waitForUser;}
		rend = vercenterpoint - ii1*GridHeight - 1;
		if (rstart < 0)
		{
			rstart = 0;
			rBin = rend - rstart + 1;
		}
		
		ii1 = ii1+1; jj1 = 0;
		for (j= horRstartpoint; j < Img1Width; j += GridWidth) //col
		{
			//cBin = GridWidth;
			cstart = horRstartpoint + jj1*GridWidth;
			if (cstart != j) {print(cstart, j); waitForUser;}
			cend = horRstartpoint + (jj1+1)*GridWidth;
			if (cend > Img1Width-1)
			{
				cend = Img1Width-1;
				cBin = cend - cstart + 1;
			}
			makeRectangle(cstart, rstart, cBin, rBin);
			getStatistics(area, mean, min, max, std);
			//print("mean--", mean, "max--", max);
			if (max-mean > speckleheight)//there is speckle
			{	hspeckleno++; 
				print("mean--", mean, "min--", min, "max--", max);
				wsRatio = max/ mean; print("white spot ratio:",wsRatio);
				if (wsRatio > 1) 
				{brightpixel++;} print("speckle location: row-", i+BorderWidth, "col-", j+BorderHeight);
			}
			else
			{
				if (ii1 < 3 && jj1 < 4)				
				{bkg=grid100ImageMean;}
				else
				{bkg= croppedImageMean;}
				
				if (mean - bkg > speckleheight) //grid area smaller that speckle
				{
					hspeckleno++; 
					print("mean--", mean, "min--", min, "max--", max);
					wsRatio = max/bkg; print("white spot ratio:",wsRatio);
					if (wsRatio>1)
					{brightpixel++;} print("speckle location: row-", i+BorderWidth, "col-", j+BorderHeight);
					//mean = GridArray_q4[0]; //GridArray_q2[GridArray_q2.length-1] //Array.getStatistics(array, min, max, mean, stdDev) 
				}
			}
			GridArray_q1 = Array.concat(GridArray_q1, mean);//4th quadrant
			jj1 = jj1+1;
			if (max-mean > speckleheight || mean - bkg > speckleheight) //if it is not a speckle, then run dark spot
			{};
			else{
			makeRectangle(cstart, rstart, cBin, rBin);
			getStatistics(area, mean, min, max, std);
			//print("mean--", mean, "max--", max);
			if (mean-min > speckleheight)//there is particle or dark spot
			{	
				print("mean--", mean, "min--", min, "max--", max);
				dsRatio = max/mean; print("dark spot ratio:",dsRatio);
			if (dsRatio > 1)
			{darkspot++;} print("darkspot location: row-", i+BorderWidth, "col-", j+BorderHeight);
			}
			}
		}
	}
	print("row:ii1--", ii1, "col:jj1---", jj1);	
	
	/**********************third quadrant***************************/
	
	ii3 = 0; GridArray_q3 = newArray();
	for (i = verDstartpoint; i < Img1Height; i += GridHeight)	//row
	{
		rBin = GridHeight; cBin = GridWidth;
		rstart = verDstartpoint + ii3*GridHeight;
		if (rstart != i) {print(rstart, i); waitForUser;}
		rend = verDstartpoint + (ii3+1)*GridHeight;
		if (rend > Img1Height-1)
		{
			rend = Img1Height-1;
			rBin = rend - rstart + 1;
		}
		
		ii3 = ii3+1; jj3 = 0;
		for (j= horcenterpoint-GridWidth; j > -GridWidth; j -= GridWidth) //col
		{
			//cBin = GridWidth;
			cstart = horcenterpoint-GridWidth - jj3*GridWidth;
			if (cstart != j) {print(cstart, j); waitForUser;}
			cend = horcenterpoint- (jj3)*GridWidth - 1;
			if (cstart < 0)
			{ //this should be last execution
				cstart = 0;
				cBin = cend - cstart + 1;
			}
			makeRectangle(cstart, rstart, cBin, rBin);
			getStatistics(area, mean, min, max, std);
			//print("mean--", mean, "max--", max);
			if (max-mean > speckleheight)//there is speckle
			{	hspeckleno++; 
				print("mean--", mean, "min--", min, "max--", max);
				wsRatio = max/ mean; print("white spot ratio:",wsRatio);
				if (wsRatio > 1) 
				{brightpixel++;} print("speckle location: row-", i+BorderWidth, "col-", j+BorderHeight);
			}
			else
			{
				if (ii3 < 3 && jj3 < 4)				
				{bkg=grid100ImageMean;}
				else
				{bkg= croppedImageMean;}
						
				if (mean - bkg > speckleheight) //grid area smaller that speckle
				{
					hspeckleno++; 
					print("mean--", mean, "min--", min, "max--", max);
					wsRatio = max/bkg; print("white spot ratio:",wsRatio);
					if (wsRatio>1)
					{brightpixel++;} print("speckle location: row-", i+BorderWidth, "col-", j+BorderHeight);
					//mean = GridArray_q4[0]; //GridArray_q2[GridArray_q2.length-1] //Array.getStatistics(array, min, max, mean, stdDev)  
				}
			}
			GridArray_q3 = Array.concat(GridArray_q3, mean);//4th quadrant
			jj3 = jj3+1;
			if (max-mean > speckleheight || mean - bkg > speckleheight) //if it is not a speckle, then run dark spot
			{};
			else{
				makeRectangle(cstart, rstart, cBin, rBin);
				getStatistics(area, mean, min, max, std);
			//print("mean--", mean, "max--", max);
			if (mean-min > speckleheight)//there is particle or dark spot
			{	
				print("mean--", mean, "min--", min, "max--", max);
				dsRatio = max/mean; print("dark spot ratio:",dsRatio);
			if (dsRatio > 1)
			{darkspot++;} print("darkspot location: row-", i+BorderWidth, "col-", j+BorderHeight);
			}
			}
		}
	}
	print("row:ii3--", ii3, "col:jj3---", jj3);	
	
	/**********************second quadrant***************************/
	
	ii2 = 0; GridArray_q2 = newArray();
	for (i = vercenterpoint-GridHeight; i > -GridHeight; i -= GridHeight)	//row
	{
		rBin = GridHeight; cBin = GridWidth;
		rstart = vercenterpoint-GridHeight - ii2*GridHeight;//== i
		if (rstart != i) {print(rstart, i); waitForUser;}
		rend = vercenterpoint - ii2*GridHeight - 1;
		if (rstart < 0)
		{
			rstart = 0;
			rBin = rend - rstart + 1;
		}
		
		ii2 = ii2+1; jj2 = 0;
		for (j= horcenterpoint-GridWidth; j > -GridWidth; j -= GridWidth) //col
		{
			//cBin = GridWidth;
			cstart = horcenterpoint-GridWidth - jj2*GridWidth;
			if (cstart != j) {print(cstart, j); waitForUser;}
			cend = horcenterpoint- jj2*GridWidth - 1;
			if (cstart < 0)
			{ //this should be last execution
				cstart = 0;
				cBin = cend - cstart + 1;
				//print(cend, cBin);
				//waitForUser;
			}
			makeRectangle(cstart, rstart, cBin, rBin);
			getStatistics(area, mean, min, max, std);
			//print("mean--", mean, "max--", max);
			if (max-mean > speckleheight)//there is speckle
			{	hspeckleno++; 
				print("mean--", mean, "min--", min, "max--", max);
				wsRatio = max/ mean; print("white spot ratio:",wsRatio);
				if (wsRatio > 1) 
				{brightpixel++;} print("speckle location: row-", i+BorderWidth, "col-", j+BorderHeight);
			}
			else
			{
				if (ii2 < 3 && jj2 < 4)				
				{bkg=grid100ImageMean;}
				else
				{bkg= croppedImageMean;}
				if (mean - bkg > speckleheight) //grid area smaller that speckle
				{
					hspeckleno++; 
					print("mean--", mean, "min--", min, "max--", max);
					wsRatio = max/bkg; print("white spot ratio:",wsRatio);
					if (wsRatio>1)
					{brightpixel++;} print("speckle location: row-", i+BorderWidth, "col-", j+BorderHeight);
					//mean = GridArray_q4[0]; //GridArray_q2[GridArray_q2.length-1] //Array.getStatistics(array, min, max, mean, stdDev)   
				}
			}
			if(isNaN(mean)) //
			{print(j, i, cBin, rBin);waitForUser;}
			GridArray_q2 = Array.concat(GridArray_q2, mean);//4th quadrant
			jj2 = jj2+1;
			if (max-mean > speckleheight || mean - bkg > speckleheight) //if it is not a speckle, then run dark spot
			{};
			else{
				makeRectangle(cstart, rstart, cBin, rBin);
				getStatistics(area, mean, min, max, std);
				//print("mean--", mean, "max--", max);
				if (mean-min > speckleheight)//there is particle or dark spot
				{	
					print("mean--", mean, "min--", min, "max--", max);
					dsRatio = max/mean; print("dark spot ratio:",dsRatio);
				if (dsRatio > 1)
				{darkspot++;} print("darkspot location: row-", i+BorderWidth, "col-", j+BorderHeight);}
			}
		}//for j
	}//for i
	print("row:ii2--", ii2, "col:jj2---", jj2);	
}	


	/******************************************************************
	 *
	 * write gridded image to screen and file
	 *
	 ******************************************************************/
	 
	close();	// close the raw image.
	//waitForUser;
	if(ii1!=ii3 && jj1!=jj2) {print("serious error 1083,please contact Level 6 R&D"), exit;}
	wdGridImg = jj1+jj2; htGridImg = ii1+ii3;
	//name = getTitle;
	dotIndex = indexOf(filename, ".");
	title = substring(filename, 0, dotIndex);
	newImage(title+"_Gridded", "16-bit black", wdGridImg, htGridImg, 1);	
	//waitForUser;
	counter = 0;
	for (row = htGridImg/2-1; row >=0; row--)
	{	//first quadrant
		for (col = wdGridImg/2; col < wdGridImg; col++)
		{
			 setPixel(col, row,GridArray_q1[counter++]);
		}
	}
	counter = 0;
	for (row = htGridImg/2-1; row >=0; row--)
	{	//second quadrant
		for (col = wdGridImg/2-1; col >= 0; col--)
		{
			 setPixel(col, row,GridArray_q2[counter++]);
		}
	}
	counter = 0;
	for (row = htGridImg/2; row < htGridImg; row++)
	{	//third quadrant
		for (col = wdGridImg/2-1; col >= 0; col--)
		{
			 setPixel(col, row,GridArray_q3[counter++]);
		}
	}
	counter = 0;
	for (row = htGridImg/2; row < htGridImg; row++)
	{	//fourth quadrant
		for (col = wdGridImg/2; col < wdGridImg; col++)
		{
			 setPixel(col, row,GridArray_q4[counter++]);
		}
	}
	print("counter: ", counter);
	updateDisplay();
	getStatistics(area, gridImageMean);
	print("grid100ImageMean-",grid100ImageMean, "gridImageMean2-", gridImageMean, "croppedImageMean-", croppedImageMean);
	//waitForUser;
	print (input);
	saveAs("Tiff", input + File.separator + getTitle() + ".tif"); // later deleted	
	gridfilename = input + File.separator+ getTitle();
	/*print ("aaaa-----",gridfilename);
	dotIndex = indexOf(gridfilename, ".");
	gridfilename = substring(gridfilename, 0, dotIndex);
	print (gridfilename);
	waitForUser;*/	
	
	/******************************************************************
	 *
	 * wrinkle lines checking module using sobel filter
	 *
	 ******************************************************************/
	//run("Convolve...", "text1=[-1 -1 -1 -1 -1\n-1 -1 -1 -1 -1\n-1 -1 24 -1 -1\n-1 -1 -1 -1 -1\n-1 -1 -1 -1 -1\n] normalize");
	//waitForUser;
	//run("Convolve...", "text1=[-1 -1 -1 -1 -1\n-1 -1 -1 -1 -1\n-1 -1 24 -1 -1\n-1 -1 -1 -1 -1\n-1 -1 -1 -1 -1\n] normalize");
	//waitForUser;
	makeRectangle(10, 0, wdGridImg-14, htGridImg); //(x, y, width, height)
	run("Crop");
	//waitForUser;
	run("Find Edges");
	getStatistics(area, wrinkle_image_mean);//getStatistics(area, mean)
	close();//close cropped image
	
	
	/******************************************************************
	 *
	 * deformities/imprints/stains check module using rollin ball method
	 *
	 ******************************************************************/

	open(gridfilename);
	run("Subtract Background...", "rolling=10");
	makeRectangle(10, 0, wdGridImg-14, htGridImg); //(x, y, width, height)
	run("Crop");
	getStatistics(area, deformity_image_mean) ;
	//waitForUser;
	close(); //close cropped image

		
	setResult("File", nResults-1, file);

	//if(resultchoice == "full detailed results") //1170-2273
	//{
	setresultdiy(resultchoice, "bright pixels<=3", nResults-1, brightpixel);
	setresultdiy(resultchoice, "dark spots<=3", nResults-1, darkspot);
	setresultdiy(resultchoice, "speckles", nResults-1, hspeckleno);
	/*setresultdiy(resultchoice, "wrinkles", nResults-1, sumall);
	setresultdiy(resultchoice, "rSquared", nResults-1, sumallr2); */
	setresultdiy(resultchoice, "wrinkles1", nResults-1, deformity_image_mean);
	setresultdiy(resultchoice, "wrinkles2", nResults-1, wrinkle_image_mean);
	
	if(deformity_image_mean < deformity_criteria)
		setresultdiy(resultchoice, "Deformity-Pass/Fail", nResults-1, "Pass");
	else
		setresultdiy(resultchoice, "Deformity-Pass/Fail", nResults-1, "Fail");
	
	if(wrinkle_image_mean < wrinkle_criteria)
		setresultdiy(resultchoice, "Wrinkle-Pass/Fail", nResults-1, "Pass");
	else
		setresultdiy(resultchoice, "Wrinkle-Pass/Fail", nResults-1, "Fail");

	if (brightpixel>3 || darkspot>3)
	{print("reject the screen due to speckles");}


	/****************************************************************
	 *
	 *diagonal uniformity check module
	 *
	 ****************************************************************/
if(1){	 
	//cov3
	open(gridfilename);
	//waitForUser;
	makeLine(0, 0,wdGridImg-1, htGridImg-1);
	diagonal_array1= newArray();
	diagonal_array2= newArray();
	diagonalratio1=newArray();
	diagonalratio2= newArray();
	diagonal_array1= getProfile();
	//Array.print(diagonal_array1);
	//waitforUser;
	diagonalarraylen = lengthOf(diagonal_array1);
	//print(diagonalarraylen);

	if (diagonalarraylen%2 == 1)
	{
		diagcenterpoint = floor(diagonalarraylen/2); //even odd number
		diagRstartpoint=diagcenterpoint+1;
	}			
	else
	{
		diagcenterpoint = (diagonalarraylen/2);
		diagRstartpoint=diagcenterpoint;
	}
		
	for (i=0; i< diagcenterpoint; i++)
	{
		diagonalratio1=Array.concat(diagonalratio1,diagonal_array1[diagcenterpoint-1-i]/diagonal_array1[diagRstartpoint+i]);
	}

	//Array.print(diagonalratio1);
	diagonalratiolen= lengthOf(diagonalratio1);
	print(diagonalratiolen);
	//waitForUser;

	Array.getStatistics(diagonalratio1, min, max, mean, stdDev);
	setresultdiy(resultchoice, "Diag-1 Mean", nResults-1, mean);
	setresultdiy(resultchoice, "Diag-1 StdDev", nResults-1, stdDev);
	if (abs(mean-1)<0.01)
		ratio = 1;
	else
		ratio = abs(mean-1)*100;
	cov3 = (stdDev*ratio)*100;
	setresultdiy(resultchoice, "Diag-1 COV", nResults-1, cov3);
	
	if(cov3<24)										
		setresultdiy(resultchoice, "D1-Pass/Fail", nResults-1, "Pass");
	else
		setresultdiy(resultchoice, "D1-Pass/Fail", nResults-1, "Fail"); 
	
		
	/*********************************
	 * Louis diagonal method -1
	 *********************************/
	exclude=4;diag1score=0;
	diagmidpointcriteria=10;
	diag1gradcrit=61;
	

	diag1gradleft=(diagonal_array1[diagcenterpoint-1]-diagonal_array1[exclude])/((diagcenterpoint)-1-exclude);
	diag1gradright=(diagonal_array1[diagonalarraylen-1-exclude]-diagonal_array1[diagRstartpoint])/(diagonalarraylen-1-exclude-diagRstartpoint);
	diag1grad=abs(diag1gradleft+diag1gradright);

	diag1peaksArrayindex=newArray();
	diag1peaksArrayindex=Array.findMaxima(diagonal_array1,0);// peak indexs of fullverprofile , first rightpeaksArrayindex element is index of maximum value of profile.
	diag1peaksArrayindexlen=lengthOf(diag1peaksArrayindex);
	diag1pindex=0;// find which index of peak Arrayindex contains the index of fullverprofile max value.
	
			
	while (diagonal_array1[diag1peaksArrayindex[diag1pindex]]>=59000) // avoid max point as saturation point.
	{
		diag1pindex++;
	}

	diag1maxindex=diag1peaksArrayindex[diag1pindex];// fullverprofile index of maximum intensity.

	diag1endpointdiff=abs(diagonal_array1[0]-diagonal_array1[diagonalarraylen-1]);
	diag1endpointcriteria= 5700 + (200*floor((diagonal_array1[diag1maxindex])/10000));
	diag1midpointdiff= abs(diag1maxindex-((diagonalarraylen/2)-0.5));

	setresultdiy(resultchoice, "Diag1 graddif", nResults-1, diag1grad);
	setresultdiy(resultchoice, "Diag1 midpointdiff", nResults-1,diag1midpointdiff );
	setresultdiy(resultchoice, "Diag1 endpointdiff", nResults-1,diag1endpointdiff );
	
	while (diag1grad>diag1gradcrit) 
	{
		diag1score=diag1score-3;
		diag1gradcrit+=10;
	}
	if (diag1midpointdiff>diagmidpointcriteria) 
	{
		diag1score=diag1score-1;
		if (diag1midpointdiff>diagmidpointcriteria+4) 
		{
			diag1score=diag1score-1;		
		}
	}
	while (diag1endpointdiff>diag1endpointcriteria) 
	{
		diag1score=diag1score-2;
		diag1endpointcriteria+=500;

	}

	setresultdiy(resultchoice, "DiagA score",nResults-1,diag1score);

	if (diag1score<=-9)
	{
		//outcome=0;
		setresultdiy(resultchoice, "diagA code check", nResults-1, "Fail-A");
		if(diag1score<=-11)
		{
			setresultdiy(resultchoice, "diagA code check", nResults-1, "Fail-B");
			if (diag1score<=-13)
			{
				setresultdiy(resultchoice, "diagA code check", nResults-1, "Fail-C");

				if (diag1score<=-15)
				{
					setresultdiy(resultchoice, "diagA code check", nResults-1, "Fail-D");
				}
			
			}
		}
	}
	else{
	
		setresultdiy(resultchoice, "diagA code check", nResults-1, "Pass-D");
		if( diag1score>=-7)
		{
			setresultdiy(resultchoice, "diagA code check", nResults-1, "Pass-C");
			if(diag1score>=-5)
			{
			setresultdiy(resultchoice, "diagA code check", nResults-1, "Pass-B");
				if (diag1score>=-3)
				{
				setresultdiy(resultchoice, "diagA code check", nResults-1, "Pass-A");
				}
			
			}
		}
	} //if (diag1score<=-9)

	//cov4
	makeLine(wdGridImg-1,0, 0, htGridImg-1);
	diagonal_array2= getProfile();
	//Array.print(diagonal_array2);
	diagonalarraylen2 = lengthOf(diagonal_array2);
	//print(diagonalarraylen2);

	if (diagonalarraylen2%2 == 1)
	{
		diagcenterpoint = floor(diagonalarraylen2/2); //even odd number
		diagRstartpoint=diagcenterpoint+1;
	}
				
	else
	{
		diagcenterpoint = (diagonalarraylen2/2);
		diagRstartpoint=diagcenterpoint;
	}
		
	for (i=0; i< diagcenterpoint; i++)
	{
		diagonalratio2=Array.concat(diagonalratio2,diagonal_array2[diagcenterpoint-1-i]/diagonal_array2[diagRstartpoint+i]);
	}

	//Array.print(diagonalratio1);
	diagonalratiolen= lengthOf(diagonalratio2);
	print(diagonalratiolen);
	//waitForUser;
	
	Array.getStatistics(diagonalratio2, min, max, mean, stdDev);
	setresultdiy(resultchoice, "Diag-2 Mean", nResults-1, mean);
	setresultdiy(resultchoice, "Diag-2 StdDev", nResults-1, stdDev);
	if (abs(mean-1)<0.01)
		ratio = 1;
	else
		ratio = abs(mean-1)*100;
	cov4 = (stdDev*ratio)*100;
	setresultdiy(resultchoice, "Diag-2 COV", nResults-1, cov4);
	
	if(cov4<5)										
		setresultdiy(resultchoice, "D2-Pass/Fail", nResults-1, "Pass");
	else
		setresultdiy(resultchoice, "D2-Pass/Fail", nResults-1, "Fail");


	if (cov3<24 && cov4<5)
		setresultdiy(resultchoice, "Diagonal Pass/Fail", nResults-1, "Diagonal Pass");
	else
		setresultdiy(resultchoice, "Diagonal Pass/Fail", nResults-1, "Diagonal Fail");
	

	close();
	
	/*********************************
	 * Louis diagonal method -2
	 *********************************/
	exclude=4;diag2score=0;
	diagmidpointcriteria=10;
	diag2gradcrit=70;
	
	diaggradleft=(diagonal_array2[diagcenterpoint-1]-diagonal_array2[exclude])/((diagcenterpoint)-1-exclude);
	diaggradright=(diagonal_array2[diagonalarraylen2-1-exclude]-diagonal_array2[diagRstartpoint])/(diagonalarraylen2-1-exclude-diagRstartpoint);
	diaggrad=abs(diaggradleft+diaggradright);

	diagpeaksArrayindex=newArray();
	diagpeaksArrayindex=Array.findMaxima(diagonal_array2,0);// peak indexs of fullverprofile , first rightpeaksArrayindex element is index of maximum value of profile.
	diagpeaksArrayindexlen=lengthOf(diagpeaksArrayindex);
	diagpindex=0;// find which index of peak Arrayindex contains the index of fullverprofile max value.
	
			
	while (diagonal_array2[diagpeaksArrayindex[diagpindex]]>=59000) // avoid max point as saturation point.
	{
		diagpindex++;
	}

	diagmaxindex=diagpeaksArrayindex[diagpindex];// fullverprofile index of maximum intensity.

	diagendpointdiff=abs(diagonal_array2[0]-diagonal_array2[diagonalarraylen2-1]);
	diagendpointcriteria= 4700 + (200*floor((diagonal_array2[diagmaxindex])/10000));
	diagmidpointdiff= abs(diagmaxindex-((diagonalarraylen2/2)-0.5));

	setresultdiy(resultchoice, "Diag2 graddif", nResults-1, diaggrad);
	setresultdiy(resultchoice, "Diag2 midpointdiff", nResults-1,diagmidpointdiff );
	setresultdiy(resultchoice, "Diag2 endpointdiff", nResults-1,diagendpointdiff );
	
	while (diaggrad>diag2gradcrit) 
	{
		diag2score=diag2score-3;
		diag2gradcrit+=10;
	}
	if (diagmidpointdiff>diagmidpointcriteria) 
	{
		diag2score=diag2score-1;
		if (diagmidpointdiff>diagmidpointcriteria+4) 
		{
			diag2score=diag2score-1;		
		}
	}
	while (diagendpointdiff>diagendpointcriteria) 
	{
		diag2score=diag2score-2;
		diagendpointcriteria+=500;

	}
	
	setresultdiy(resultchoice, "diagB score",nResults-1,diag2score);
	
	if (diag2score<=-9)
	{
		setresultdiy(resultchoice, "diagB code check", nResults-1, "Fail-A");
		if(diag2score<=-11)
		{
			setresultdiy(resultchoice, "diagB code check", nResults-1, "Fail-B");
			if (diag2score<=-13)
			{
			setresultdiy(resultchoice, "diagB code check", nResults-1, "Fail-C");

				if (diag2score<=-15)
				{
					setresultdiy(resultchoice, "diagB code check", nResults-1, "Fail-D");
				}
			
			}
		}
	}
	else {
		

		setresultdiy(resultchoice, "diagB code check", nResults-1, "Pass-D");
		if( diag2score>=-7)
		{
			setresultdiy(resultchoice, "diagB code check", nResults-1, "Pass-C");
			if(diag2score>=-5)
			{
				setresultdiy(resultchoice, "diagB code check", nResults-1, "Pass-B");
				if (diag2score>=-3)
				{
					setresultdiy(resultchoice, "diagB code check", nResults-1, "Pass-A");
				}
			
			}
		}
	}


	if (diag1score>-9 && diag2score>-9)
		setresultdiy(resultchoice, "Diagonal Pass/Fail", nResults-1, "Diagonal Pass");
	else
		setresultdiy(resultchoice, "Diagonal Pass/Fail", nResults-1, "Diagonal Fail");

}	
	//--------------------------------------------------------------------------------------------------------

	//============for production line only as grid image not needed for them====================
	if (del_grid_image){
		File.delete(gridfilename);}
	//waitForUser;

	/*****************************************************
	 * Horizontal uniformity check module
	 * this module does not need any image opened
	 * Louis method - horizontal
	 *****************************************************/
if(1){		
	horscore=0;
	horgraddifArr=newArray();hormidpointdiffArr=newArray();horendpointdiffArr=newArray();
	horendpointpasscriteria=newArray();


	exclude=4;  // exclude array index 0-6, 78-83.
	 
	midpointcriteria=10;
	horgradcrit=51;

	if ((Img1Height-1)%GridHeight !=0) 
	{
		vercolgridno= (floor((Img1Height-1)/GridHeight))+2;// total no of grids in column =84
	}
	else
	{
		vercolgridno= ((Img1Height-1)/GridHeight);
	}
	if ((Img1Width-1)%GridWidth !=0) 
	{
		horrowgridno= (floor((Img1Width-1)/GridWidth))+2;// total no of grids in row =108
	}
	else
	{
		horrowgridno= ((Img1Width-1)/GridWidth);
	}
	shadescore=0;
	shademeanscore=newArray();
	
	for (i = 0; i < vercolgridno/2; i++) //0-41
	{

		fullhorprof1=newArray();fullhorprof2=newArray();fullhorprof=newArray();// combining the 2 quandrants array elements into fullverprof for right side.
		rightmaxxprofval_1=newArray();rightmaxxprofval_2=newArray();rightmaxhorprof1=newArray();rightmaxhorprof2=newArray();// right screen side
		fullhorprof3=newArray();fullhorprof4=newArray();fullhorprof5=newArray();
		leftmaxxprofval_1=newArray();leftmaxxprofval_2=newArray();leftmaxhorprof1=newArray();leftmaxhorprof2=newArray();//left screen side
		shadegradient=newArray(); shadegradient2=newArray();shadecount=0;
		
		//best-fit line plot excludes first 6 intensity values from left and right with steep intensity increase .
		
		for (k = 0; k < horrowgridno/2; k++)  //k=0-53
		{
			fullhorprof1=Array.concat(fullhorprof1,GridArray_q2[(i*(horrowgridno/2))+((horrowgridno/2)-1-k)]);
			fullhorprof2=Array.concat(fullhorprof2,GridArray_q1[k+(i*horrowgridno/2)]);
			fullhorprof3=Array.concat(fullhorprof3,GridArray_q3[(i*(horrowgridno/2))+((horrowgridno/2)-1-k)]);//left side
			fullhorprof4=Array.concat(fullhorprof4,GridArray_q4[k+(i*horrowgridno/2)]);//left screen side
		
		}
		 
		fullhorprof     = Array.concat(fullhorprof,fullhorprof1,fullhorprof2);// from top to bottom, first array element is top element. Full profile of right side ver column
		fullhorprof5    = Array.concat(fullhorprof5,fullhorprof3,fullhorprof4); // full array of left side ver column
		fullhorprof5len = lengthOf(fullhorprof5);
		fullhorproflen  = lengthOf(fullhorprof);

			
		rightpeaksArrayindex=newArray();leftpeaksArrayindex=newArray();

		//=====find all the peaks of right screen side column
		rightpeaksArrayindex=Array.findMaxima(fullhorprof,0);// peak indexs of fullverprofile , first rightpeaksArrayindex element is index of maximum value of profile.
		rightpeaksArrayindexlen=lengthOf(rightpeaksArrayindex);
		rightpindex=0;// find which index of peak Arrayindex contains the index of fullverprofile max value.
		
				
		while (fullhorprof[rightpeaksArrayindex[rightpindex]]>=59000) // avoid max point as saturation point.
		{
			rightpindex++;
		}

		if (rightpeaksArrayindex[rightpindex]<(exclude+1))
		{
			rightpeaksArrayindex[rightpindex]=(exclude+1);
		}
		
		if (rightpeaksArrayindex[rightpindex]>(horrowgridno-exclude-2) )
		{
			rightpeaksArrayindex[rightpindex]=(horrowgridno-exclude-2);
		}

			
		rightmaxindex=rightpeaksArrayindex[rightpindex];// fullverprofile index of maximum intensity.
		//print ("maximumpoint index---",rightmaxindex);
	
		
		newgradleft=(fullhorprof[(horrowgridno/2)-1]-fullhorprof[exclude])/((horrowgridno/2)-1-exclude);
		newgradright=(fullhorprof[horrowgridno-1-exclude]-fullhorprof[horrowgridno/2])/(horrowgridno-1-exclude-(horrowgridno/2));
		newgrad=abs(newgradleft+newgradright);
		
		for (p = 0; p < (horrowgridno/2)-1 ; p+=shadeinterval) 
		{
			endaaa=p+shadeinterval-1;
			if (endaaa>(horrowgridno/2)-1)
			{
				endaaa=(horrowgridno/2)-1;
			}
			
			shadegrad=(fullhorprof[endaaa]-fullhorprof[p])/(shadeinterval-1);
			shadegradient=Array.concat(shadegradient,shadegrad);
		}
		shadegradlen=lengthOf(shadegradient);
		for (p = 1 ; p < shadegradlen; p++)
		{
			if(p<=2){
                tmpa = shadegradient[p-1];
                tmpb = shadegradient[p];
            }
            else {
                tmpa = shadegradient[p-2];
                tmpb = shadegradient[p];
            }
			//if(shadegradient[p]>shadegradient[p-1]) //[p-1]
			if(tmpb > tmpa) //[p-1] //[p-1]
			{
				shadescore++;
			}
            print(p, "---", shadescore);
			
		}
			
		//shademeanscore=Array.concat(shademeanscore,shadescore);
		endpointdiff = abs(fullhorprof[0]-fullhorprof[fullhorproflen-1]);
		midpointdiff = abs(rightmaxindex-((horrowgridno/2)-0.5));


		endpointcriteria= 2200 + 1800*0 + (200*floor((fullhorprof[rightmaxindex])/10000));
		horendpointpasscriteria=Array.concat(horendpointpasscriteria,endpointcriteria);
		print("toprowno----",(vercolgridno/2)-1-i,"newgradleft",newgradleft,"newgradright",newgradright,"graddiff--",newgrad,"endpointdiff----", endpointdiff,"endpointdiff criteria",endpointcriteria,"midpointdiff---", midpointdiff);

		horgraddifArr=Array.concat(horgraddifArr,newgrad);hormidpointdiffArr=Array.concat(hormidpointdiffArr,midpointdiff);horendpointdiffArr=Array.concat(horendpointdiffArr,endpointdiff);

		//=====find all the peaks of left screen side column
		leftpeaksArrayindex=Array.findMaxima(fullhorprof5,1);// peak indexs of fullverprofile , first rightpeaksArrayindex element is index of maximum value of profile.
		Array.print(leftpeaksArrayindex);
		leftpeaksArrayindexlen=lengthOf(leftpeaksArrayindex);
		leftpindex=0;// find which index of peak Arrayindex contains the index of fullverprofile max value.

		
		while (fullhorprof5[leftpeaksArrayindex[leftpindex]]>=59000)// avoid max point as saturation point.
		{
			leftpindex++;
		}

		if (leftpeaksArrayindex[leftpindex]<(exclude+1))
		{
			leftpeaksArrayindex[leftpindex]=(exclude+1);
		}
			
		if (leftpeaksArrayindex[leftpindex]>(horrowgridno-exclude-2) )
		{
			leftpeaksArrayindex[leftpindex]=(horrowgridno-exclude-2);
		}


		
		leftmaxindex=leftpeaksArrayindex[leftpindex];// fullverprofile index of maximum intensity.
		
		newgradleft=(fullhorprof5[(horrowgridno/2)-1]-fullhorprof5[exclude])/((horrowgridno/2)-1-exclude);
		newgradright=(fullhorprof5[horrowgridno-1-exclude]-fullhorprof5[horrowgridno/2])/(horrowgridno-1-exclude-(horrowgridno/2));
		newgrad=abs(newgradleft+newgradright);
		for (p = 0; p < (horrowgridno/2)-1 ; p+=shadeinterval) 
		{
			endaaa=p+shadeinterval-1;
			if (endaaa>(horrowgridno/2)-1)
			{
				endaaa=(horrowgridno/2)-1;
			}

			shadegrad=(fullhorprof5[endaaa]-fullhorprof5[p])/(shadeinterval-1);
			shadegradient2=Array.concat(shadegradient2,shadegrad);
		}
		shadegradlen=lengthOf(shadegradient2);
		for (p = 1 ; p < shadegradlen; p++)
		{
			if(p<=2){
                tmpa = shadegradient2[p-1];
                tmpb = shadegradient2[p];
            }
            else {
                tmpa = shadegradient2[p-2];
                tmpb = shadegradient2[p];
            }
			//if(shadegradient2[p]>shadegradient2[p-1])
			if(tmpb > tmpa) //[p-1]
			{		
				shadescore++;
			}
			print(p, "---", shadescore);
			
		}
			
		shademeanscore=Array.concat(shademeanscore,shadescore);
		endpointdiff=abs(fullhorprof5[0]-fullhorprof5[fullhorprof5len-1]);
		midpointdiff= abs(leftmaxindex-((horrowgridno/2)-0.5));


		endpointcriteria= 2200 + 1800*0 + (200*floor((fullhorprof5[leftmaxindex])/10000));
		horendpointpasscriteria=Array.concat(horendpointpasscriteria,endpointcriteria);

		print("bottomrowno----",(vercolgridno/2)+i,"newgradleft",newgradleft,"newgradright",newgradright,"graddiff--",newgrad,"endpointdiff----", endpointdiff,"endpointdiff criteria",endpointcriteria,"midpointdiff---", midpointdiff);

		horgraddifArr=Array.concat(horgraddifArr,newgrad);hormidpointdiffArr=Array.concat(hormidpointdiffArr,midpointdiff);horendpointdiffArr=Array.concat(horendpointdiffArr,endpointdiff);

	
	} //for i loop
	
	Array.getStatistics(shademeanscore, min, max, shademeanvalue, stdDev);

	setresultdiy(resultchoice, "shade score", nResults-1, shademeanvalue);
	if (shademeanvalue> (shadecriteria))
	{
		setresultdiy(resultchoice, "shade check", nResults-1, "Shade present");
	}
	else{
		setresultdiy(resultchoice, "shade check", nResults-1, "Shade absent");
	}

	Array.getStatistics(horgraddifArr, min, max, horgraddifmean, stdDev);
	Array.getStatistics(hormidpointdiffArr, min, max, hormidpointdiffmean, stdDev);
	Array.getStatistics(horendpointdiffArr, min, max, horendpointdiffmean, stdDev);
	Array.getStatistics(horendpointpasscriteria, min, max, horendpointpassmean, stdDev);


	setresultdiy(resultchoice, "horgradiffmean", nResults-1, horgraddifmean);

	setresultdiy(resultchoice, "hormidpointdiffmean", nResults-1, hormidpointdiffmean);
	setresultdiy(resultchoice, "horendpointdiffmean", nResults-1, horendpointdiffmean);
	setresultdiy(resultchoice, "horendpointpasscriteria",nResults-1, horendpointpassmean);


	while (horgraddifmean>horgradcrit) 
	{
		
		horscore=horscore-3;
		horgradcrit+=10;
	}
	
	if (hormidpointdiffmean>midpointcriteria) 
	{
		
		horscore=horscore-1;
		if (hormidpointdiffmean>midpointcriteria+4) 
		{
			horscore=horscore-1;		
		}
	}
	while (horendpointdiffmean>horendpointpassmean) 
	{
		//endpointfail++;
		horscore=horscore-2;
		horendpointpassmean+=500;

	}
	
	setresultdiy(resultchoice, "horscore", nResults-1, horscore);
	if (horscore<=-9)
	{
		//outcome=0;
		setresultdiy(resultchoice, "hor code check", nResults-1, "Fail-A");
		if(horscore<=-11)
		{
			setresultdiy(resultchoice, "hor code check", nResults-1, "Fail-B");
			if (horscore<=-13)
			{
			setresultdiy(resultchoice, "hor code check", nResults-1, "Fail-C");

				if (horscore<=-15)
				{
					setresultdiy(resultchoice, "hor code check", nResults-1, "Fail-D");
				}
			
			}
		}
		

	}
	else {
		
		setresultdiy(resultchoice, "hor code check", nResults-1, "Pass-D");
		if( horscore>=-7)
		{
			setresultdiy(resultchoice, "hor code check", nResults-1, "Pass-C");
			if(horscore>=-5)
			{
			setresultdiy(resultchoice, "hor code check", nResults-1, "Pass-B");
				if (horscore>=-3)
				{
				setresultdiy(resultchoice, "hor code check", nResults-1, "Pass-A");
				}
			
			}
		}
	}


	/*****************************************
	 * horizontal symmetry method 1
	 *****************************************/

	print("line368-", wdGridImg*htGridImg/4, GridArray_q1.length, GridArray_q2.length, GridArray_q3.length, GridArray_q4.length);
	hProfile_q1 = newArray(); hProfile_q2 = newArray(); 
	hProfile_q3 = newArray(); hProfile_q4 = newArray();
	hProfile12 = newArray();  hProfile34 = newArray();
	sum12 = newArray(); sum34 = newArray();
	sum12r2 = newArray(); sum34r2 = newArray();
	xcor = newArray();
	rowno=0; 
	
	for (i=0; i<wdGridImg; i++){
		xcor = Array.concat(xcor, i);
	}
	
	for (i=0; i< wdGridImg*htGridImg/4; i++)
	{
		hSymmetryRatio1 = Array.concat(hSymmetryRatio1, GridArray_q1[i]/GridArray_q2[i]);
		hSymmetryRatio2 = Array.concat(hSymmetryRatio2, GridArray_q4[i]/GridArray_q3[i]);
		hProfile_q1 = Array.concat(hProfile_q1, GridArray_q1[i]);
		hProfile_q2 = Array.concat(hProfile_q2, GridArray_q2[i]);
		hProfile_q3 = Array.concat(hProfile_q3, GridArray_q3[i]);
		hProfile_q4 = Array.concat(hProfile_q4, GridArray_q4[i]);
		//print("i-",i, "-wdGridImg/2-", wdGridImg/2);
		if ( (i+1)%(wdGridImg/2) == 0 )
		{
			//one row
			/*
			rowno++;
			hProfile34 = Array.concat( Array.reverse(hProfile_q3), hProfile_q4); //left to right
			hProfile12 = Array.concat( Array.reverse(hProfile_q2), hProfile_q1); //left to right
							   
			Fit.doFit("8th Degree Polynomial",xcor,hProfile12); //20 Equation can be either the equation name or an index. 
				
			REy12 = newArray(xcor.length); 
			for (j=0; j<wdGridImg; j++){
				REy12[j] = abs(hProfile12[j] - Fit.f(j));  	
			}
										 
			Array.getStatistics(REy12, min, max, mean, stdDev);
			sum12 = Array.concat(sum12, mean*lengthOf(REy12));
			sum12r2 = Array.concat(sum12r2, Fit.rSquared);
	
			Fit.doFit("8th Degree Polynomial",xcor,hProfile34); //20

			REy34 = newArray(xcor.length);
			for (j=0; j<wdGridImg; j++){
				REy34[j] = abs(hProfile12[j] - Fit.f(j));  				
			}
			//Array.show(xcor, hProfile12, REy34);
			Array.getStatistics(REy34, min, max, mean, stdDev);
			sum34 = Array.concat(sum34, mean*lengthOf(REy34));
			sum34r2 = Array.concat(sum34r2, Fit.rSquared);

			//exit();
			hProfile_q1 = newArray(); hProfile_q2 = newArray(); 
			hProfile_q3 = newArray(); hProfile_q4 = newArray();
			hProfile12 = newArray();  hProfile34 = newArray();
			*/
		}//if
	
	} //for i end
	/*sumwrinkle = newArray(); sumwrinkler2 = newArray();
	//print(rowno, sum12.length, sum34.length);
	sumwrinkle = Array.concat(sum12, sum34);
	sumwrinkler2 = Array.concat(sum12r2, sum34r2);
	Array.getStatistics(sumwrinkle, min, max, mean, stdDev);
	sumall = mean*sumwrinkle.length;
	Array.getStatistics(sumwrinkler2, min, max, mean, stdDev);
	sumallr2 = mean*sumwrinkler2.length;*/
	
	Array.getStatistics(GridArray_q1,MIN,MAX,MEAN1,STDDEV);
	Array.getStatistics(GridArray_q2,MIN,MAX,MEAN2,STDDEV);
	Array.getStatistics(GridArray_q3,MIN,MAX,MEAN3,STDDEV);
	Array.getStatistics(GridArray_q4,MIN,MAX,MEAN4,STDDEV);
	g1 = MEAN1+MEAN4-MEAN2-MEAN3;
	g2 = MEAN3+MEAN4-MEAN1-MEAN2;
	
	hSymmetryRatio = Array.concat(hSymmetryRatio1, hSymmetryRatio2);
	Array.getStatistics(hSymmetryRatio, min, max, mean, stdDev);

	/*setresultdiy(resultchoice, "wrinkles", nResults-1, sumall);
	setresultdiy(resultchoice, "rSquared", nResults-1, sumallr2); */
	
	//setresultdiy(resultchoice, "Hor Mean", nResults-1, mean);
	//setresultdiy(resultchoice, "Hor StdDev", nResults-1, stdDev);
	if (abs(mean-1)<0.01)
		ratio = 1;
	else
		ratio = abs(mean-1)*100;
	cov1 = (stdDev*ratio)*100;
	setresultdiy(resultchoice, "HorCOV", nResults-1, cov1);
	setresultdiy(resultchoice, "H-skewness", nResults-1, g1);
	if(cov1<6)
		setresultdiy(resultchoice, "H-Pass/Fail", nResults-1, "Pass");
	else
		setresultdiy(resultchoice, "H-Pass/Fail", nResults-1, "Fail");
}	

	
	/**********************************
	 * vertical uniformity check
	 * ver visual check
	 **********************************/
if(1){	 
	//setresultdiy(resultchoice, "File", nResults, file);
	gradfail=0;midpointfail=0;endpointfail=0;verscore=0;

	vergraddifArr=newArray();vermidpointdiffArr=newArray();verendpointdiffArr=newArray();
	endpointpasscriteria=newArray();


	exclude=4;  // exclude array index 0-6, 78-83.


	midpointcriteria=10; //20211009 10
	vergradcrit=52+8;      //20211009 52

	if ((Img1Height-1)%GridHeight !=0) 
	{
		vercolgridno= (floor((Img1Height-1)/GridHeight))+2;// total no of grids in column =84
	}
	else
	{
		vercolgridno= ((Img1Height-1)/GridHeight);
	}
	if ((Img1Width-1)%GridWidth !=0) 
	{
		horrowgridno= (floor((Img1Width-1)/GridWidth))+2;// total no of grids in row =108
	}
	else
	{
		horrowgridno= ((Img1Width-1)/GridWidth);
	}

	 
	for (k = 0; k < horrowgridno/2; k++) 
	{

		verprof1=newArray();verprof2=newArray();verprof3=newArray();verprof4=newArray();// shortening of fullverprof by excluding the 6 values from left and right of column profile.
		fullverprof1=newArray();fullverprof2=newArray();fullverprof=newArray();// combining the 2 quandrants array elements into fullverprof for right side.
		rightmaxxprofval_1=newArray();rightmaxxprofval_2=newArray();rightmaxverprof1=newArray();rightmaxverprof2=newArray();// right screen side
		fullverprof3=newArray();fullverprof4=newArray();fullverprof5=newArray();
		leftmaxxprofval_1=newArray();leftmaxxprofval_2=newArray();leftmaxverprof1=newArray();leftmaxverprof2=newArray();//left screen side
		
		//best-fit line plot excludes first 6 intensity values from left and right with steep intensity increase .
		
		for (i = 0; i < vercolgridno/2; i++) 
		{
			fullverprof1=Array.concat(fullverprof1,GridArray_q1[k+(((vercolgridno/2)-1-i)*horrowgridno/2)]);
			fullverprof2=Array.concat(fullverprof2,GridArray_q4[k+(i*horrowgridno/2)]);
			fullverprof3=Array.concat(fullverprof3,GridArray_q2[k+(((vercolgridno/2)-1-i)*horrowgridno/2)]);//left side
			fullverprof4=Array.concat(fullverprof4,GridArray_q3[k+(i*horrowgridno/2)]);//left screen side
		
		}
		 
		fullverprof=Array.concat(fullverprof,fullverprof1,fullverprof2);// from top to bottom, first array element is top element. Full profile of right side ver column
		fullverprof5=Array.concat(fullverprof5,fullverprof3,fullverprof4); // full array of left side ver column
		

		rightpeaksArrayindex=newArray();leftpeaksArrayindex=newArray();

		//=====find all the peaks of right screen side column
		rightpeaksArrayindex=Array.findMaxima(fullverprof,0);// peak indexs of fullverprofile , first rightpeaksArrayindex element is index of maximum value of profile.
		rightpeaksArrayindexlen=lengthOf(rightpeaksArrayindex);
		rightpindex=0;// find which index of peak Arrayindex contains the index of fullverprofile max value.
		
				
		while (fullverprof[rightpeaksArrayindex[rightpindex]]>=59000) // avoid max point as saturation point.
		{
			rightpindex++;
		}

		if (rightpeaksArrayindex[rightpindex]<(exclude+1))
		{
			rightpeaksArrayindex[rightpindex]=(exclude+1);
		}
		
		if (rightpeaksArrayindex[rightpindex]>(vercolgridno-exclude-2) )
		{
			rightpeaksArrayindex[rightpindex]=(vercolgridno-exclude-2);
		}

		
		rightmaxindex=rightpeaksArrayindex[rightpindex];// fullverprofile index of maximum intensity.
		//print ("maximumpoint index---",rightmaxindex);
		
		
		fullverprof1len=lengthOf(fullverprof1);
		fullverprof2len=lengthOf(fullverprof2);
		fullverproflen=lengthOf(fullverprof);
		
		newgradleft=(fullverprof[(vercolgridno/2)-1]-fullverprof[exclude])/((vercolgridno/2)-1-exclude);
		newgradright=(fullverprof[vercolgridno-1-exclude]-fullverprof[vercolgridno/2])/(vercolgridno-1-exclude-(vercolgridno/2));
		newgrad=abs(newgradleft+newgradright);
			
			
		endpointdiff=abs(fullverprof[0]-fullverprof[fullverproflen-1]);

		midpointdiff= abs(rightmaxindex-((vercolgridno/2)-0.5));
		
		
		endpointcriteria= 2200 + 1800*0 + (200*floor((fullverprof[rightmaxindex])/10000));
		endpointpasscriteria=Array.concat(endpointpasscriteria,endpointcriteria);
		print("rightcolumnno----",k+(horrowgridno/2),"newgradleft",newgradleft,"newgradright",newgradright,"graddiff--",newgrad,"endpointdiff----", endpointdiff,"endpointdiff criteria-----",endpointcriteria, "midpointdiff---", midpointdiff);

		//count the no. of fails for each right column profile (taking reference from center width pixel.)
		
		if (newgrad>vergradcrit) 
		{
			gradfail++;
		} 
		if (midpointdiff>midpointcriteria) 
		{
			midpointfail++;
		} /*
		if (interceptdiff>interceptcriteria) 
		{
			interceptfail++;
		} */
		if (endpointdiff>endpointcriteria) 
		{
			endpointfail++;
		}
		
		vergraddifArr=Array.concat(vergraddifArr,newgrad);vermidpointdiffArr=Array.concat(vermidpointdiffArr,midpointdiff);verendpointdiffArr=Array.concat(verendpointdiffArr,endpointdiff);


		//=====find all the peaks of left screen side column
		leftpeaksArrayindex=Array.findMaxima(fullverprof5,1);// peak indexs of fullverprofile , first rightpeaksArrayindex element is index of maximum value of profile.
		Array.print(leftpeaksArrayindex);
		leftpeaksArrayindexlen=lengthOf(leftpeaksArrayindex);
		leftpindex=0;// find which index of peak Arrayindex contains the index of fullverprofile max value.

		
		while (fullverprof5[leftpeaksArrayindex[leftpindex]]>=59000)// avoid max point as saturation point.
		{
			leftpindex++;
		}

		if (leftpeaksArrayindex[leftpindex]<(exclude+1))
		{
			leftpeaksArrayindex[leftpindex]=(exclude+1);
		}
			
		if (leftpeaksArrayindex[leftpindex]>(vercolgridno-exclude-2) )
		{
			leftpeaksArrayindex[leftpindex]=(vercolgridno-exclude-2);
		}

		leftmaxindex=leftpeaksArrayindex[leftpindex];// fullverprofile index of maximum intensity.
		
		fullverprof5len=lengthOf(fullverprof5);
		
		newgradleft=(fullverprof5[(vercolgridno/2)-1]-fullverprof5[exclude])/((vercolgridno/2)-1-exclude);
		newgradright=(fullverprof5[vercolgridno-1-exclude]-fullverprof5[vercolgridno/2])/(vercolgridno-1-exclude-(vercolgridno/2));
		newgrad=abs(newgradleft+newgradright);

		endpointdiff=abs(fullverprof5[0]-fullverprof5[fullverprof5len-1]);

		midpointdiff= abs(leftmaxindex-((vercolgridno/2)-0.5));

		endpointcriteria= 2200 + 1800*0 + (200*floor((fullverprof5[leftmaxindex])/10000));
		endpointpasscriteria=Array.concat(endpointpasscriteria,endpointcriteria);

		print("leftcolumnno----",(horrowgridno/2)-1-k,"newgradleft",newgradleft,"newgradright",newgradright,"graddiff--",newgrad,"endpointdiff----", endpointdiff,"endpointdiff criteria-----",endpointcriteria, "midpointdiff---", midpointdiff);
		  

		
		vergraddifArr=Array.concat(vergraddifArr,newgrad);vermidpointdiffArr=Array.concat(vermidpointdiffArr,midpointdiff);verendpointdiffArr=Array.concat(verendpointdiffArr,endpointdiff);

		//count the no. of fails for each column profile
		 
	 
		if (newgrad>vergradcrit) 
		{
			gradfail++;
		} 
		if (midpointdiff>midpointcriteria) 
		{
			midpointfail++;
		}
		if (endpointdiff>endpointcriteria) 
		{
			endpointfail++;
		}
		

	} //for k loop 1907

	Array.getStatistics(vergraddifArr, min, max, vergraddifmean, stdDev);
	Array.getStatistics(vermidpointdiffArr, min, max, vermidpointdiffmean, stdDev);
	Array.getStatistics(verendpointdiffArr, min, max, verendpointdiffmean, stdDev);
	Array.getStatistics(endpointpasscriteria, min, max, verendpointpassmean, stdDev);




	setresultdiy(resultchoice, "ver gradiffmean", nResults-1, vergraddifmean);

	setresultdiy(resultchoice, "ver midpointdiffmean", nResults-1, vermidpointdiffmean);
	setresultdiy(resultchoice, "ver endpointdiffmean", nResults-1, verendpointdiffmean);

	setresultdiy(resultchoice, "ver endpointpasscriteria",nResults-1, verendpointpassmean);

	//print the number of fails for each factor among all columns:
	//setresultdiy(resultchoice, "maxgraddifffail", nResults-1, maxgradfail);
	setresultdiy(resultchoice, "ver midpointdifffail", nResults-1, midpointfail);
	setresultdiy(resultchoice, "ver gradfail", nResults-1, gradfail);
	setresultdiy(resultchoice, "ver endpointdifffail", nResults-1, endpointfail);


	while (vergraddifmean>vergradcrit) 
	{
		gradfail++;
		verscore=verscore-3;
		vergradcrit+=10;
	}
		
	if (vermidpointdiffmean>midpointcriteria) 
	{
		//midpointfail++;
		verscore=verscore-1;
		if (vermidpointdiffmean>midpointcriteria+4) 
		{
			verscore=verscore-1;		
		}
	}
	while (verendpointdiffmean>verendpointpassmean) 
	{
		//endpointfail++;
		verscore=verscore-2;
		verendpointpassmean+=500;

	}
		
	setresultdiy(resultchoice, "ver score", nResults-1, verscore);
	if (verscore<=-9)
	{
		//outcome=0;
		setresultdiy(resultchoice, "ver code check", nResults-1, "Fail-A");
		if(verscore<=-11)
		{
			setresultdiy(resultchoice, "ver code check", nResults-1, "Fail-B");
			if (verscore<=-13)
			{
				setresultdiy(resultchoice, "ver code check", nResults-1, "Fail-C");

				if (verscore<=-15)
				{
					setresultdiy(resultchoice, "ver code check", nResults-1, "Fail-D");
				}
			
			}
		}
		
		/*
		else if (score<=-16)
		{
		setresultdiy(resultchoice, "ver code check", nResults-1, "Fail-E");
		} */
	}
	else {
		
		//outcome=1;	
		setresultdiy(resultchoice, "ver code check", nResults-1, "Pass-D");
		if( verscore>=-7)
		{
			setresultdiy(resultchoice, "ver code check", nResults-1, "Pass-C");
			if(verscore>=-5)
			{
				setresultdiy(resultchoice, "ver code check", nResults-1, "Pass-B");
				if (verscore>=-3)
				{
					setresultdiy(resultchoice, "ver code check", nResults-1, "Pass-A");
				}
			
			}
		}
	}

	/*****************************************
	 * vertical symmetry method 1
	 *****************************************/
	
	for (i=0; i< wdGridImg*htGridImg/4; i++)
	{
		vSymmetryRatio1 = Array.concat(vSymmetryRatio1, GridArray_q4[i]/GridArray_q1[i]);
		vSymmetryRatio2 = Array.concat(vSymmetryRatio2, GridArray_q3[i]/GridArray_q2[i]);
	}
	vSymmetryRatio = Array.concat(vSymmetryRatio1, vSymmetryRatio2);
	Array.getStatistics(vSymmetryRatio, min, max, mean, stdDev);
	//setresultdiy(resultchoice, "Ver Mean", nResults-1, mean);
	//setresultdiy(resultchoice, "Ver StdDev", nResults-1, stdDev);
	if (abs(mean-1)<0.01)
		ratio = 1;
	else
		ratio = abs(mean-1)*100;
	cov2 = (stdDev*ratio)*100;
	setresultdiy(resultchoice, "Ver COV", nResults-1, cov2);
	setresultdiy(resultchoice, "V-skewness", nResults-1, g2);
	print("g2", g2);
	if(cov2<4.3)										
		setresultdiy(resultchoice, "V-Pass/Fail", nResults-1, "Pass");
	else
		setresultdiy(resultchoice, "V-Pass/Fail", nResults-1, "Fail");
	
	wrinkle1score=0;
	if(deformity_image_mean<deformity_criteria)
	{
		wrinkle1score=-20;
		if(deformity_image_mean<deformity_criteria-5)
		{
			wrinkle1score=-16;
			if(deformity_image_mean<deformity_criteria-10)
			{
				wrinkle1score=-12;
				if(deformity_image_mean<deformity_criteria-15)
				{
					wrinkle1score=-8;
					if(deformity_image_mean<deformity_criteria-20)
					{
						wrinkle1score=-4;
						if(deformity_image_mean<deformity_criteria-25)
						{
							wrinkle1score=0;
						}
					}		
				}			
			}		
		}
	}


	overallscore=100+diag1score+diag2score+horscore+verscore+wrinkle1score;

	if (diag1score>-9 && diag2score>-9 && horscore>-9 && verscore>-9 ) {
		setresultdiy(resultchoice, "Uniformity Pass/Fail", nResults-1, "Uniformity Pass");
	}
	else {
		setresultdiy(resultchoice, "Uniformity Pass/Fail", nResults-1, "Uniformity Fail");
	}

	if (diag1score>-9 && diag2score>-9 && horscore>-9 && verscore>-9 && wrinkle_image_mean<wrinkle_criteria && brightpixel<3 && darkspot <3 && hspeckleno<3 && deformity_image_mean<deformity_criteria && shademeanvalue<= shadecriteria )
	{	setresultdiy(resultchoice, "Overall Channel Pass/Fail", nResults-1, "Overall Channel Pass");
		outcome=overallscore;
	}
	else {
		setresultdiy(resultchoice, "Overall Channel Pass/Fail", nResults-1, "Overall Channel Fail");
		outcome=-300;
	}
	return outcome;

}
	//} //(resultchoice=="full detailed results")


}//function uniformity_check(input, file)
function setresultdiy(option,head,row,value)
{
	if (resultchoice=="full detailed results")
		setResult(head, row, value);
	else if (resultchoice=="screen outcome")
		print(head, row, value);
}
function derivmean(array) //not used
{
	
	c=0;
	Arraymean=0;
	arrlen = lengthOf(array);
	
	print("array length is: ", array.length);
	
	for (i=0; i < arrlen; i++)
	{
			c+= array[i];
					
	}
		
	Arraymean=c/array.length;

	
	return Arraymean;

}

function Arraymin(array) //not used
{
		
	Arrmin=0;
	arrlen = lengthOf(array);
	
	if(array[0]<=array[arrlen-1])
			Arrmin=array[arrlen-1];
		else					
	Arrmin=array[0];
			
	return Arrmin;
}

function MedianOfArray(array, value) //not used
{
	root1=0; root2=0;
	c=0;
	arrlen = lengthOf(array);
	indices=newArray();
	//print("array length is: ", array.length);
	//find first root
	for (i=0; i < arrlen-1; i++)
	{
		if ((array[i]<=value) && (array[i+1]>value)) 
		{
			root1 = i;
			//print("i--", i, "of ", arrlen, " array[i]---", array[i], "value ", value, " array[i+1]---", array[i+1], " root1---", root1);
			i=1e99;
			
		}
		else
		{
		//indices = Array.concat(indices, root1);
			//i = 1e99;
			//print("quit loop by assign i=1e99");
			
		}
	 }
	//if (root1 == 0)
		//waitForUser;
	//find 2nd root	
	root2 = 0;
	for (i=arrlen-1; i>0; i--)
	{
		if ((array[i]<=value) && (array[i-1]>value)) 
		{
			root2 = i;
			//print("i--", i, "of ", arrlen, " array[i]---", array[i], "value ", value, " array[i-1]---", array[i-1], " root2---", root2);
			i=0;
		}
		else
		{
		
		//indices = Array.concat(indices, arrlen);
		//i=0;
		}
	 } 
	//if (root2 == 0)
		//waitForUser;
	c = (root2+root1)/2; //calculate center position
	return c;

}

function IndexOfArray(array, value, roots) //not used
{	//return the index of given value in array
	root1=0; root2=0; index = 0;
	c=0;
	arrlen = lengthOf(array);
	indices=newArray();
	//print("array length is: ", array.length);
	//find first root
	for (i=0; i < arrlen-1; i++)
	{
		if ((array[i]<=value) && (array[i+1]>value)) 
		{
			roots[index] = i;
			index++;
			//print("i--", i, "of ", arrlen, " array[i]---", array[i], "value ", value, " array[i+1]---", array[i+1], " root1---", root1);
			//i=1e99;				
		}
		else
		{
			print("no index found");
		}
	 }
	//if (root1 == 0)
		//waitForUser;
	//find 2nd root	
	root2 = 0;
	for (i=arrlen-1; i>0; i--)
	{
		if ((array[i]<=value) && (array[i-1]>value)) 
		{
			roots[index] = i;
			index++;
			//print("i--", i, "of ", arrlen, " array[i]---", array[i], "value ", value, " array[i-1]---", array[i-1], " root2---", root2);
			//i=0;
		}
		else
		{
			print("no index found");
		}
	 } 
	//if (root2 == 0)
		//waitForUser;
	c = index-1;
	if (c != roots.length){
		waitForUser;}
	return c;
	  
}
function getBar(p1, p2) {
	n = 20;
	bar1 = "--------------------";
	bar2 = "********************";
	index = round(n*(p1/p2));
	if (index<1) index = 1;
	if (index>n-1) index = n-1;
	return substring(bar2, 0, index) + substring(bar1, index+1, n);
}