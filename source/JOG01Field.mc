using Toybox.Application as App;
        using Toybox.WatchUi as Ui;
        using Toybox.Graphics as Graphics;
        using Toybox.System as System;

//! @author Konrad Paumann
class JOG01Field extends App.AppBase {

    function getInitialView() {
        var view = new JOG01View();
        return [ view ];
    }
}

//! A DataField that shows some infos.
//!
//! @author Konrad Paumann
class JOG01View extends Ui.DataField {

      hidden const CENTER = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
    hidden const HEADER_FONT = Graphics.FONT_SYSTEM_XTINY;
    hidden const VALUE_FONT = Graphics.FONT_NUMBER_MEDIUM;
    hidden const ZERO_TIME = "0:00";
    hidden const ZERO_DISTANCE = "0.00";
   
    hidden var kmOrMileInMeters = 1000;
    hidden var is24Hour = true;
    hidden var distanceUnits = System.UNIT_METRIC;
    hidden var textColor = Graphics.COLOR_BLACK;
    hidden var inverseTextColor = Graphics.COLOR_WHITE;
    hidden var backgroundColor = Graphics.COLOR_WHITE;
    hidden var inverseBackgroundColor = Graphics.COLOR_BLACK;
    hidden var inactiveGpsBackground = Graphics.COLOR_LT_GRAY;
    hidden var batteryBackground = Graphics.COLOR_WHITE;
    hidden var batteryColor1 = Graphics.COLOR_GREEN;
    hidden var hrColor = Graphics.COLOR_RED;
    hidden var lapColor = Graphics.COLOR_DK_BLUE;
    hidden var headerColor = Graphics.COLOR_DK_GRAY;
       
    hidden var paceStr, avgPaceStr, hrStr, distanceStr, durationStr,lapPaceStr;
   
    hidden var paceData = new DataQueue(10);
    hidden var paceLapData = new DataQueue(30);
    hidden var timeLapData = new DataQueue(30);
    hidden var distLapData = new DataQueue(30);
   
    hidden var paceData30 = new DataQueue(30);
    hidden var paceData3 = new DataQueue(3);
    
    hidden var distData = new DataQueue2(30);
    hidden var timeData = new DataQueue2(30);
    
    hidden var doUpdates = 0;
   
    hidden var speed = 0;
    hidden var avgSpeed= 0;
    hidden var maxSpeed= 0;
    hidden var hr = 0;
    hidden var avghr = 0;
    hidden var maxhr = 0;
    hidden var distance = 0;
    hidden var elapsedTime = 0;
    hidden var gpsSignal = 0;
   
    hidden var currentCadence = 0;
    hidden var averageCadence = 0;
    hidden var maxCadence = 0;
   
   
     //lap
    hidden var compteurLap = 0;
    hidden var distLap=0;
    hidden var distLapStr;
    hidden var durationLap;
    hidden var timeLap=0;
    hidden var timeLapTmp=0;
    hidden var distLapCourant=0;
    hidden var timeLapCourant=0;
    hidden var speedLap = 0;
    hidden var speedLapCourant = 0;
    hidden var timeLapStr=ZERO_TIME;
    hidden var distLapOnLap = 0;
   
    //
    hidden var ascension=0;
    hidden var switchData = 0;
    hidden var switchDataPrec = 0;
   
   
    hidden var hasBackgroundColorOption = false;
    hidden var cpt = 0;
    hidden var afficheSpeed = true;
   
   
    var rolling;
    var slideCad = 0;
    var slideSpd = 0.0;
    var slideTime = 0;
   
    var lapDist = 100;
   
       
    function initialize() {
        DataField.initialize();
        rolling = new TidyData(lapDist);
    }
   
    function onTimerLap(){
        compteurLap ++;
        speedLapCourant = speedLap;
        distLapOnLap = distLap;
        distLapCourant = distance != null ? distance : 0;
        timeLapTmp = elapsedTime - timeLapCourant;
        timeLapCourant = elapsedTime != null ? elapsedTime : 0;
        if (timeLapTmp != null && timeLapTmp > 0) {
             timeLapStr = msToTime(timeLapTmp,0);
        } else {
            timeLapStr = ZERO_TIME;
        }
       
        if (timeLap != null && timeLap > 0) {
            if (timeLap < 2000 &&  switchData != 2){
                switchDataPrec = switchData;
                switchData = 2;
            }
            else if (timeLap < 6000){
            	//rolling.reset();           
                if (switchData == 0){
                    switchData = 1;
                }else{
                    if (switchData == 2){
                        switchData = switchDataPrec;
                    }
                    else{
                        switchData = 0;
                    }
                }
            }else if (timeLap > 15000){
               paceLapData.add(getMinutesPerKmOrMile(speedLapCourant));
               distLapData.add(convertDistance(distLapOnLap));
               timeLapData.add(timeLapStr);
            }
        }
       
     
        //afficheLap();
       

    }

    //! The given info object contains all the current workout
    function compute(info) {
        cpt = cpt + 1;
       
        if (cpt == 1){
            cpt = 0;
            if (afficheSpeed){
                afficheSpeed = false;
            }else{
                afficheSpeed = true;
            }
        }
   
        if (info.currentSpeed != null) {
            paceData.add(info.currentSpeed);
            paceData30.add(info.currentSpeed);
            paceData3.add(info.currentSpeed);
        } else {
            paceData.reset();
            paceData30.reset();
            paceData3.reset;
        }
       
        if (info.elapsedDistance != null){
        	distData.slide();
            distData.add(info.elapsedDistance);
       		//distData.affiche();
       		//System.println(distData.diffData());
        }
        
        if (info.elapsedTime != null){
        	timeData.slide();
            timeData.add(info.elapsedTime);
       		//timeData.affiche();
       		//System.println("temps : "  + distData.diffData() + " - " + timeData.diffData());
       		if (timeData.diffData()>0){
       		   //System.println("vitesse " + getMinutesPerKmOrMile(distData.diffData().toDouble()/(timeData.diffData().toDouble()/1000)));
       		}
        }
        speed = info.currentSpeed != null ? info.currentSpeed : 0;
        avgSpeed = info.averageSpeed != null ? info.averageSpeed : 0;
        maxSpeed = info.maxSpeed != null ? info.maxSpeed : 0;
        elapsedTime = info.timerTime != null ? info.timerTime : 0;       
        hr = info.currentHeartRate != null ? info.currentHeartRate : 0;
        avghr = info.averageHeartRate != null ? info.averageHeartRate : 0;
        maxhr = info.maxHeartRate != null ? info.maxHeartRate : 0;
        distance = info.elapsedDistance != null ? info.elapsedDistance : 0;
        gpsSignal = info.currentLocationAccuracy != null ? info.currentLocationAccuracy : 0;
       
        speed = speed * 3.6;

        maxCadence = info.maxCadence != null ? info.maxCadence : 0;
        averageCadence = info.averageCadence != null ? info.averageCadence : 0;
        currentCadence = info.currentCadence != null ? info.currentCadence : 0;
       
       
        ascension = info.totalAscent != null ? info.totalAscent : 0;
   
        if (compteurLap == 0){
            speedLap = avgSpeed;
            distLap=distance;
            timeLap=elapsedTime;
        }else{
            if (elapsedTime != null &&  distance != null){
                distLap = distance - distLapCourant;
                timeLap =  elapsedTime - timeLapCourant;
               
                if (distLap>0 && timeLap>0){
                    var timeLapSecond = timeLap / 1000;
                    if (timeLapSecond != null && timeLapSecond > 0.2){
                        speedLap = distLap / timeLapSecond;
                    }else{
                        speedLap = 0;
                    }
                  
                }else{
                    speedLap = 0;
                }
            }
        }
       
       
       if (
            info.elapsedTime == null ||
            info.startTime == null || // if we haven't started, we don't calc here
            info.elapsedDistance == null ) { return; }
        //rolling
        rolling.add(info.elapsedDistance, info.timerTime, info.currentCadence);
       
        //System.println("rolling ready : " + rolling.ready);
        if ( rolling.ready ) {
               //slideCad = rolling.cadTotal / rolling.timeTotal / cadDiv;
            slideSpd = 3.6 * rolling.distTotal / rolling.timeTotal ;
            slideTime = (1000 * lapDist * rolling.timeTotal / rolling.distTotal).toNumber();
            //System.println("slideTIme : " + slideTime + " - " + slideSpd + " - " + getMinutesPerKmOrMile(slideSpd/3.6));
        }

    }
   
    function onLayout(dc) {
        setDeviceSettingsDependentVariables();
        //onUpdate(dc);
    }
   
    function onShow() {
        doUpdates = true;
        return true;
    }
   
    function onHide() {
        doUpdates = false;
    }
   
    function onUpdate(dc) {
        if(doUpdates == false) {
            return;
        }
       
        setColors();
        // reset background
        dc.setColor(backgroundColor, backgroundColor);
        dc.fillRectangle(0, 0, 218, 218);
       
        drawValues(dc);
    }

    function setDeviceSettingsDependentVariables() {
        hasBackgroundColorOption = (self has :getBackgroundColor);
    }
   
    function setColors() {
        if (hasBackgroundColorOption) {
            backgroundColor = getBackgroundColor();
            //TODO:pour les tests
            //backgroundColor = Graphics.COLOR_BLACK;
            textColor = (backgroundColor == Graphics.COLOR_BLACK) ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
            inverseTextColor = (backgroundColor == Graphics.COLOR_BLACK) ? Graphics.COLOR_WHITE : Graphics.COLOR_WHITE;
            inverseBackgroundColor = (backgroundColor == Graphics.COLOR_BLACK) ? Graphics.COLOR_DK_GRAY: Graphics.COLOR_BLACK;
            hrColor = (backgroundColor == Graphics.COLOR_BLACK) ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
            headerColor = (backgroundColor == Graphics.COLOR_BLACK) ? Graphics.COLOR_LT_GRAY: Graphics.COLOR_DK_GRAY;
            batteryColor1 = (backgroundColor == Graphics.COLOR_BLACK) ? Graphics.COLOR_BLUE : Graphics.COLOR_DK_GREEN;
            lapColor = (backgroundColor == Graphics.COLOR_BLACK) ? Graphics.COLOR_GREEN : Graphics.COLOR_DK_BLUE;
        }
    }
   

       
    function drawValues(dc) {
         //time
        var clockTime = System.getClockTime();
        var time = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%.2d")]);
         
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0,0,218,20);
        dc.setColor(inverseTextColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(106, 10, Graphics.FONT_TINY, time, CENTER);
        var battery = System.getSystemStats().battery;
        dc.drawText(147, 10, Graphics.FONT_TINY,battery.format("%d"), CENTER);
 
        var computeAvgSpeed = computeAverageSpeed(paceData);
        var computeAvgSpeed30 = computeAverageSpeed(paceData30);
      
       
        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
       
        if (switchData == 2){
            afficheLap(dc);
        }else{
       
       
            //timeLap
            var durationLap;
            if (timeLap != null && timeLap > 0) {
                 durationLap=msToTime(timeLap,0);
            } else {
                durationLap = ZERO_TIME;
            }
           
           
            //duration
            var duration;
            var timeEtude = elapsedTime;
            //timeEtude = 5580180;
            if (timeEtude != null && timeEtude > 0) {
                duration = msToTime(timeEtude,0);
            } else {
                duration = ZERO_TIME;
            }
   
            var avgSpeedKmh = avgSpeed * 3.6;
            if (switchData == 0){
                dc.drawText(dc.getWidth()/2+2, 50, Graphics.FONT_NUMBER_HOT, duration, CENTER);
                dc.drawText(37, 62,Graphics.FONT_NUMBER_MILD,msToTime(timeEtude,1), CENTER);
            }else{
                dc.drawText(dc.getWidth()/2+2, 50, Graphics.FONT_NUMBER_HOT, durationLap, CENTER);//duration  
            }
   
           
   
   
   
           
            dc.drawText(200, 163, HEADER_FONT, "km", CENTER);
            
            
                    //tendance speed
            if (switchData == 0 && timeLap>10000){
                if (avgSpeed<3.33333333){
                //if (avgSpeed>(speedLap+0.02)){
                    dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
                    //drawBlocSpeed(dc,avgSpeed,speedLap,120);
                    //if (getDiffSpeed(3.33333333,avgSpeed)>=0){
            		//dc.fillPolygon([[20+decalage,81],[20+decalage, 95],[31+decalage,88]]);
				     //dc.fillRectangle(0, 81, 240, 69);
        			//}  
                //}else if (speedLap>(avgSpeed+0.02)){
                }else if (avgSpeed>3.47222222){
                     dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
                     //if (getDiffSpeed(speedLap,avgSpeed)>=0){
            		  //dc.fillPolygon([[20+decalage,81],[20+decalage, 95],[31+decalage,88]]);
				      //dc.fillRectangle(0, 81, 240, 69);
        			//}  
                }
                
              
            }
            
            dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
            
            var vitesse = speed;
           
           
            if (switchData == 0){
                dc.drawText(dc.getWidth()/2, 180, Graphics.FONT_NUMBER_HOT, convertDistance(distance), CENTER);//convertDistance(distance)
                
                if (speedLap>avgSpeed){
                	//dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                }
                
                if (speedLap<avgSpeed){
                	//dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
                }
                
                dc.drawText(75 , 118, Graphics.FONT_NUMBER_THAI_HOT,getMinutesPerKmOrMile(avgSpeed), CENTER); // avgSpeedKmh.format("%.1f")
          		dc.drawText(dc.getWidth() /2+76, 131, Graphics.FONT_NUMBER_MEDIUM,getMinutesPerKmOrMile(speedLap) , CENTER);
          		dc.drawText(dc.getWidth() /2+80 , 97, Graphics.FONT_NUMBER_MILD,getMinutesPerKmOrMile(vitesse / 3.6), CENTER);//getMinutesPerKmOrMile(vitesse1 / 3.6)
          		
          		//dc.drawText(75 , 118, Graphics.FONT_NUMBER_THAI_HOT,"4:25", CENTER); // avgSpeedKmh.format("%.1f")
          		//dc.drawText(dc.getWidth() /2+76, 131, Graphics.FONT_NUMBER_MEDIUM,"4:25" , CENTER);
          		//dc.drawText(dc.getWidth() /2+80 , 97, Graphics.FONT_NUMBER_MILD,"4:55", CENTER);//getMinutesPerKmOrMile(vitesse1 / 3.6)
          		
          		
          		
          		//dc.drawText(dc.getWidth() /2+60, 121, Graphics.FONT_NUMBER_MEDIUM,getMinutesPerKmOrMile(computeAvgSpeed30) , CENTER);
          	    
          	    //dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
          		
            }else{
                dc.drawText(dc.getWidth()/2, 180, Graphics.FONT_NUMBER_HOT, convertDistance(distLap), CENTER);//convertDistance(distance)
                dc.drawText(70 , 118, Graphics.FONT_NUMBER_HOT,getMinutesPerKmOrMile(vitesse / 3.6), CENTER); // avgSpeedKmh.format("%.1f")
               
               
                if (speedLap<1.67){
                    dc.drawText(dc.getWidth() /2+60, 121, Graphics.FONT_NUMBER_MEDIUM,getMinutesPerKmOrMile(speedLap) , CENTER);
                }else{
                    dc.drawText(dc.getWidth() /2+60, 121, Graphics.FONT_NUMBER_HOT,getMinutesPerKmOrMile(speedLap) , CENTER);
                }
            }
            
            if (slideSpd > 0){
                //vitesse = slideSpd;
            }
            //System.println( timeData.diffData() + " - " +  distData.diffData());
            if (timeData.diffData()>0 && distData.diffData()>0){
       		   //vitesse  = distData.diffData().toDouble()/(timeData.diffData().toDouble()/1000)*3.6;
       		   //System.println("vitesse " + getMinutesPerKmOrMile(distData.diffData().toDouble()/(timeData.diffData().toDouble()/1000)));
       		}    
                
            if (vitesse/3.6<1.67){
                //dc.drawText(dc.getWidth() /2-60 , 121, Graphics.FONT_NUMBER_MEDIUM,getMinutesPerKmOrMile(vitesse / 3.6) , CENTER);
            }else{
            	//dc.drawText(dc.getWidth() /2-60 , 121, Graphics.FONT_NUMBER_HOT,getMinutesPerKmOrMile(vitesse / 3.6) , CENTER);
            } 
           
           
           
   
    
   			
   			if (timeLap>10000){
   			    if (computeAvgSpeed>speedLap && speedLap>0){
	                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
	                //drawBlocSpeed(dc,computeAvgSpeed,speedLap,0);
	            }else if (speedLap>computeAvgSpeed && speedLap>0){
	                 dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
	                 //drawBlocSpeed(dc,speedLap,computeAvgSpeed,0);
	            }
   			}

   
            //GRID
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(0,80, dc.getWidth(), 80);
            dc.drawLine(0,81, dc.getWidth(), 81);
            dc.drawLine(0,150, dc.getWidth(), 150);
            dc.drawLine(0,151, dc.getWidth(), 151);
           
            dc.drawLine(dc.getWidth()/2+30,81, dc.getWidth()/2+30, 150);
            dc.drawLine(dc.getWidth()/2+30,112, dc.getWidth()/2+120, 112);
           
     
                   
            // gps
            if (gpsSignal <= 2) {
               dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
               //dc.drawText(22, 152, HEADER_FONT, "GPS", CENTER);
            }
         
            if (hr<150){
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);   
                dc.fillRectangle(0,209,240,31);
            }else if (hr>=150 && hr<160){
                 dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
                 dc.fillRectangle(0,209,240,31);
            }else if (hr>=160 && hr<170){
                 dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
                 dc.fillRectangle(0,209,240,31);
            }else if (hr>=170 && hr<180){
                 dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
                 dc.fillRectangle(0,209,240,31);
            }else if (hr>=180){
                 dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
                 dc.fillRectangle(0,209,240,30);
            }
           
                   
            //HR
            dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth()/2 ,219, Graphics.FONT_MEDIUM, hr.format("%d"), CENTER);// hr.format("%d")
            
            var vitesse1 = speed;
            if (timeData.diffData()>0 && distData.diffData()>0){
       		   vitesse1  = distData.diffData().toDouble()/(timeData.diffData().toDouble()/1000)*3.6;
       		   //System.println("vitesse " + getMinutesPerKmOrMile(distData.diffData().toDouble()/(timeData.diffData().toDouble()/1000)));
       		}    
            //dc.drawText(dc.getWidth() /2-25 , 217, Graphics.FONT_SYSTEM_XTINY,getMinutesPerKmOrMile(vitesse / 3.6), CENTER);//getMinutesPerKmOrMile(vitesse1 / 3.6)
            
        }
 
    }


    function drawBlocSpeed(dc, speed1, speed2,decalage){
        if (getDiffSpeed(speed1,speed2)>=0){
            //dc.fillPolygon([[20+decalage,81],[20+decalage, 95],[31+decalage,88]]);
			dc.fillRectangle(decalage+40, 81, 38, 14);
        }       
    }
   

    function computeAverageSpeed(tableau) {
        var size = 0;
        var data = tableau.getData();
        var sumOfData = 0.0;
        for (var i = 0; i < data.size(); i++) {
            if (data[i] != null) {
                sumOfData = sumOfData + data[i];
                size++;
            }
        }
        if (sumOfData > 0) {
            return sumOfData / size;
        }
        return 0.0;
    }
   
  
   
    function msToTime(ms,isHour) {
        var seconds = (ms / 1000) % 60;
        var minutes = (ms / 60000) % 60;
        var hours = ms / 3600000;
       
        if (isHour){
            if (hours>0){
                if (hours<10){
                    return hours.format("%02d");
                }else{
                    return hours.format("%d");
                }
            }else{
                return "";
            }
        }else{
            if (minutes < 10){
                return Lang.format("$1$:$2$", [minutes.format("%d"), seconds.format("%02d")]);
            }
            //else if (minutes >10 && hours ==""){
            //    return Lang.format("$1$:$2$", [minutes.format("%02d"), seconds.format("%02d")]);
            //}else{
            //    return Lang.format("$1$:$2$:$3$", [hours.format("%02d"),minutes.format("%02d"), seconds.format("%02d")]);
            //}
            else{
                return Lang.format("$1$:$2$", [minutes.format("%02d"), seconds.format("%02d")]);
            }   
        }
    }
   
     function convertDistance(metres) {
        var result;
       
        if( metres == null ) {
            result = 0;
        } else {
           result = metres / 1000.0;
       }
       
        return Lang.format("$1$", [result.format("%.2f")]);
    }
   
    function getMinutesPerKmOrMile(speedMetersPerSecond) {
        if (speedMetersPerSecond != null && speedMetersPerSecond > 0.2) {
            var metersPerMinute = speedMetersPerSecond * 60.0;
            var minutesPerKmOrMilesDecimal = kmOrMileInMeters / metersPerMinute;
            var minutesPerKmOrMilesFloor = minutesPerKmOrMilesDecimal.toNumber();
            var seconds = (minutesPerKmOrMilesDecimal - minutesPerKmOrMilesFloor) * 60;
            return minutesPerKmOrMilesDecimal.format("%2d") + ":" + seconds.format("%02d");
        }
        return ZERO_TIME;
    }
   
    function afficheLap(dc) {
        //todo bug affiche dernier si rotation data
        var data = paceLapData.getData();
        var datat = timeLapData.getData();
        var datad = distLapData.getData();
       
        var y=50;
        dc.drawText(75, 28, Graphics.FONT_TINY,"Vit", CENTER);
        dc.drawText(125, 28, Graphics.FONT_TINY,"Tmps", CENTER);
        dc.drawText(175, 28, Graphics.FONT_TINY,"Dist", CENTER);
        for (var i = 29; i >=0 ; i--) {
           if (data[i] != null){
                   //System.println(data[0] +" - " + datat[0] + " - " + datad[0]);
                   if (switchData == 2){
                       dc.drawText(60, y, Graphics.FONT_TINY,data[i], CENTER);
                       dc.drawText(125, y, Graphics.FONT_TINY,datat[i], CENTER);
                       dc.drawText(185, y, Graphics.FONT_TINY,datad[i], CENTER);
                   }
                    y = y + 25;
           }
          
      
        }
    }
   

    function getDiffSpeed(speedMetersPerSecond1,speedMetersPerSecond2) {
        //speedMetersPerSecond1 must be >= speedMetersPerSecond2
        var secondesPerKmOrMilesDecimal1 = 0;
        if (speedMetersPerSecond1 != null && speedMetersPerSecond1 > 0.2) {
            var metersPerMinute1 = speedMetersPerSecond1 * 60.0;
            var minutesPerKmOrMilesDecimal1 = kmOrMileInMeters / metersPerMinute1;
            secondesPerKmOrMilesDecimal1 =  minutesPerKmOrMilesDecimal1 * 60;
        }

        var secondesPerKmOrMilesDecimal2 = 0;
        if (speedMetersPerSecond2 != null && speedMetersPerSecond2 > 0.2) {
            var metersPerMinute2 = speedMetersPerSecond2 * 60.0;
            var minutesPerKmOrMilesDecimal2 = kmOrMileInMeters / metersPerMinute2;
            secondesPerKmOrMilesDecimal2 =  minutesPerKmOrMilesDecimal2 * 60;
        }

        if (secondesPerKmOrMilesDecimal1>0 &&  secondesPerKmOrMilesDecimal2>0){
            return secondesPerKmOrMilesDecimal2 - secondesPerKmOrMilesDecimal1;
        }else{
            return 0;
        }
    }

}

//! A circular queue implementation.
//! @author Konrad Paumann
class DataQueue {

    //! the data array.
    hidden var data;
    hidden var maxSize = 0;
    hidden var pos = 0;

    //! precondition: size has to be >= 2
    function initialize(arraySize) {
        data = new[arraySize];
        maxSize = arraySize;
    }
   
    //! Add an element to the queue.
    function add(element) {
        data[pos] = element;
        pos = (pos + 1) % maxSize;
    }
   
    //! Reset the queue to its initial state.
    function reset() {
        for (var i = 0; i < data.size(); i++) {
            data[i] = null;
        }
        pos = 0;
    }
   
    //! Get the underlying data array.
    function getData() {
        return data;
    }
}


//! A circular queue implementation.
//! @author Konrad Paumann
class DataQueue2 {

    //! the data array.
    hidden var data;
    hidden var maxSize = 0;
    hidden var pos = 0;
    hidden var difference = 0;

    //! precondition: size has to be >= 2
    function initialize(arraySize) {
        data = new[arraySize];
        maxSize = arraySize;
    }
   
    //! Add an element to the queue.
    function add(element) {
    	//System.print("pos " + pos + " ");
        data[pos] = element;
        if (pos < maxSize-1){
        	pos = pos + 1;
        }
    }
    
    function slide(){
    	if (data[maxSize-1] != null){
    		for (var i=0;i<data.size()-1;i++){
    			data[i] = data[i+1];
    		}
    	}
    }
   
    //! Reset the queue to its initial state.
    function reset() {
        for (var i = 0; i < data.size(); i++) {
            data[i] = null;
        }
        pos = 0;
    }
   
    //! Get the underlying data array.
    function getData() {
        return data;
    }
    
    function affiche() {
    	if(data[maxSize-1] != null){
    		for (var i = 0; i < data.size(); i++) {
           		System.print(data[i]);
           		System.print(" ");
        	}
       		 //System.println("saut : " + (data[maxSize-1].toDouble() - data[0].toDouble()));
    	}
        
    }
    
    function diffData(){
    	if(data[maxSize-1] != null){
    		return data[maxSize-1].toDouble() - data[0].toDouble();
    	}else {
    		return 0;
    	}
    }
    

}