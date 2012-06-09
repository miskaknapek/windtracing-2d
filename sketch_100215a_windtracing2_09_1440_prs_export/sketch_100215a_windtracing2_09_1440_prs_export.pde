/*


date started:  090911

name:   windtracing 2 - paris version ( 20100215 )

[ prerequisites for running:   the Processing programming environment - get it here: http://processing.org/download ]

This sketch traces wind movement.
The thinner line usually starting at the top left shows longer-term wind movements, moving in the compass direction that the wind blows in.
The larger line starting at the screen centre is a zoomed in view of the current wind blowing - with the historical data tracing back, as it were.

keys/usage:
relax and watch :) 
otherwise:
shift             - pauses/resumes playback
arrow left/right  - set playback to go backwards or forwards
[ / ]             - to skip backwards/forwards one week in time.


*/




/*
 
//////////   programming notes    //////////
 
 a function to trace the windline
 that takes the wind data and generates some coordinate points
 based on it.
 
 more precisely,
 it uses the wind direction and wind speed to generate a
 line of coordinates. ( each wind speed + direction becomes one vector,
 which translates to two coordinate points (start and finish)
 
 on top of this, we want to create some extra coordinates,
 which find a point, between the start and end point of 
 the generated coordinates.
 then generate a line, which has its centerpoint
 at the abovementioned point.
 (or, we could make that user-adjustable as well 
 - the user could indicate a multiplier of each half-length
 length of the line [ a value of zero would indicate that
 no line be created - or well, it wouldn't matter,
 one could just draw something 0 in length :) ]
 the generated line also has its angle set by the user...
 ...oh yes, the 'normal' line length is that of the 
 distance between the two points (i.e. it corresponds to windspeed)
 
 so, the following arrays should be created
 
 x/y-coords <-- the start and end points of the vector
 (after the first vector, only one coord pair per wind speed/dir value
 x/y centerpoints <-- the point between the start and end point of 
 each vector. the point between start & end 
 is given by the user, as a decimal.
 
 ctr_pt -> line_beg_x <-- these arrays hold the vectors 
 ctr_pt -> line_beg_y      from the centerpoints
 to the edges of the 'diagonal' 
 line....
 ctr_pt -> line_end_x    
 ctr_pt -> line_end_y
 
 */




// lifesavers

// this one is mostly for the coords generation
int debug = 2;
// and another, more specific for drawing
int debug_b = 2;
// and another for the unscaled background line darwing
int backg_line_debug = 2;
// and for the time date things
int debug_fetch_time_date_changes = 2;


// crucial...
import processing.opengl.*;
// saving pdfs?
import processing.pdf.*;
boolean saveOnePDFframe = false ;



// are we saving frames?
// and a speed hog of a difference
boolean save_frames = false ;
String saveFrame_filename = "windtracing_2_09_frames/windtracing_2_09_frames-######.png" ;

// - this is not disabled as, even though we're not using it, 
//   there's a function we once wrote that uses it,
//    and this sketch won't run without it... :-(
// set up the offscreen drawing area
PGraphics offscreen_drawing_area ;



//  stagesize
// - - - - - - - - - - 


/* - momentarily disabling so we can set the size in absolute numbers
 int stage_width = int( 1920*0.90 ) ;
 int stage_height = int( 1200*0.90 ) ;
 */
int stage_width = int( 1440 ) ;
int stage_height = int( 960 ) ;


// the backgorund color
color background_colour = color( 255 );




// // drawing class instantiations

// the overall view (nonmagnified)
Draw_all our_draw_all = new Draw_all();
// the zoomed in version
Zoomed_view_draw our_zoomed_view_draw;

// a font for the..text?
PFont el_font;



// what we're drawing
//  - - - - - - - - - - 

/*
note: we might want to draw several of these...drawing classes
 ... so probably this global assignment is only
 a temporary thing
 */

// the normal lines and the zoomed in lines

// this sets whether we're showing all points, nonmagnified (i.e. draw all points alias)
boolean drawing_all_pts_nonmagnified = true;
// this sets whether we're drawing the start and and points of the coords
// in the overall view
boolean drawing_all_pts_nonmagnified_weather_vector_pts = true;
// this sets whether we're drawing the cross lines in the zoomed in view
boolean drawing_all_pts_nonmagnified_cross_lines = false;


// and the same for the zoomed in view
// drawing the zoomed in view
boolean drawing_zoomed_in_view = true;
// vector start/end points
boolean drawing_zoomed_in_view_weather_vector_pts = true;
// cross lines
boolean drawing_zoomed_in_view_cross_lines = true;



////  (drawing) christmas colours ? ? 

// zoomed in bits...only... for now...
boolean doing_christmas_zoomed_centerline_stroke_colours = false;
boolean doing_christmas_zoomed_cross_lines_colours = false;
// the colours themselves...
color[] christmas_colours = { 
  color(180,0,0, 128 ), color(180,0,0, 128 ), 
  color(0,180,0, 128 ), color(0,180,0, 128 ), 
  color(0,0,180, 128), color(0,0,180, 128) };








////  time plotting
// --------------------------------------------------
//



////   ----  drawing the time as a string on the bottom right...?   ----


// this holds all the time stamps, as an array of strings
String[] timestamps_array ;



boolean doing_timendate_drawing = true;
// colours
color time_colour = color( 255, 0, 255, 111 );
// position
float time_left_offset_x = stage_width - 190 ;
float time_top_offset_y = stage_height - 20 ;





////  ----   drawing the time as a visual mark...?   ----


//      - the settings above 'just' print the time in the corner
//        this draws additional cross lines on the screen, 
//        to show time passages

// on/off switches

//  the big on / off switch
// NOTE   this also indicates 
// whether the time changes array is set up in the setup!!
boolean drawing_visual_time_indications = true; 


// where to store things
// (yes, change the data type of this, later, if more precision is needed)
int[] dateNtime_changes_array;

// NOTE:
//   there are four arrays holding the cross strokes of for the 
//   visual time indication cross lines, along with the other 
//   coordinate arrays
// NOTE:

// time change threshold for markups
// i.e. 'under' which number/level of date change
// do we draw a time indication.
// i.e.2 - do we draw a date/time change indication on year/month/day/hour/min/sec change?
// i.e.3 - if date_change_array number is <= threshold, do the markup
//         sooo, if threshold == hour/3, then if there's a year/month/day change, that'll trigger the markup too
int timedate_change_markup_threshold = 3 ;


// ___ the 'time-line' visual characteristics 

// colour?
color time_indic_vis_colour = color( 255, 0, 255, 64 );
// stroke width
float time_indic_vis_stroke_strokeWeight = 4.0;

// --  indicies 

// the indicies for the different dates/time in the timestamp string
int year_pos = 0;
int month_pos = 1;
int day_pos = 2;
int hour_pos = 3;
int min_pos = 4;
int second_pos = 5;

// the numbers indicating different kinds of time changes
// - note that both these could be used 
/*
int year_change = 0;
 int month_change = 1;
 int day_change = 2;
 int hour_change = 3;
 int min_change = 4;
 int second_change = 5;
 */
int year_change = 5;
int month_change = 4;
int day_change = 3;
int hour_change = 2;
int min_change = 1;
int second_change = 0;



//  --  visual markup parameters  -- 


// stroke colour and stroke weight

// size - as a decimal of the cross stroke vector
// (NOTE: this is subject to scaling )
float visual_time_change_markup_cross_stroke_length = 15;

// left or right side of line

// offset from left or right side - as a decimal of the cross stroke vector







//// colouring the line according to temperature?

// for the non-zoomed view... not working on this yet.
boolean doing_temperature_colouring_of_nonzoomed_in_wind_vector_line = true ;
float temperature_coloured_non_zoomed_in_wind_vector_line = 101 ;

boolean doing_temperature_colouring_of_nonzoomed_in_cross_strokes = false;
float temperature_coloured_non_zoomed_in_cross_strokes = 255;

// zoomed in view,  central line
boolean doing_temperature_colouring_of_zoomed_in_wind_vector_line = false;
// the transparency of the temp coloured zoomed in main line stroke
float temperature_coloured_zoomed_in_wind_vector_line_transparency = 180;

// the cross strokes
boolean doing_temperature_colouring_of_zoomed_in_cross_strokes = true ;
float temperature_coloured_zoomed_in_main_cross_stroke_transparency = 108 ;









// stroke parameters
//  - - - - - - - - - - 

// zoomed in line
// zoomed in line stroke colour
int zoomed_in_line_general_weather_coords_stroke_transp = 101 ;
color zoomed_in_line_general_weather_coords_stroke_colour = color( 200, zoomed_in_line_general_weather_coords_stroke_transp );
// stroke width of the magnified line
float zoomed_in_line_general_weather_coords_stroke_width = 0.02;
// cross stroke
// the colour of the cross stroke
int zoomed_in_line_cross_line_stroke_transp = 101 ;
color zoomed_in_line_cross_line_stroke_color = color( 200, zoomed_in_line_cross_line_stroke_transp );
// the stroke weight
float zoomed_in_line_cross_line_stroke_weight = 5.0;


// overall / zoomed none line rendering - line parameters
// and this is the other stroke colour...
int nonzoomed_line_general_weather_coords_stroke_transp = 148;
color nonzoomed_line_general_weather_coords_stroke_colour = color( 200, nonzoomed_line_general_weather_coords_stroke_transp );
// stroke weight 
float nonzoomed_line_general_weather_coords_stroke_weight = 1.5;

// and this is cross line paramters
color nonzoomed_line_cross_line_stroke_colour = color( 128, 128 );
// stroke weight 
float nonzoomed_line_cross_line_stroke_weight = 0.5;


/* 
 
 NOTE!   the time indication colours are elsewhere!!!
 NOTE!   the time indication colours are elsewhere!!!   ( a little further up, with the other time markup parameters )
 NOTE!   the time indication colours are elsewhere!!!
 
 
 */



// - - - - - - - -- - - - - - 
// and the general weather data tracing

//// some more specific wind data parameters
float start_point_x = stage_width*0.83 ;
float start_point_y = stage_height*0.15 ;

/*
// for testing purposes
 float start_point_x = 0 ;
 float start_point_y = 0 ;
 */

// the speed at which the wind moves
// (also used as a kind of 'scaling factor'
float wind_speed_one_meter_per_second_is_what_unit = 0.15 ;


// zoomed view left|top offset
float zoomed_view_screen_space_left_offset_x = 0.0;
float zoomed_view_screen_space_top_offset_y = 00.0;
// zoomed view size
float zoomed_view_width = stage_width ;
float zoomed_view_height = stage_height ;
// zoomed view magnification
// (larger number = larger magnification)
float zoomed_view_magnification = 11;



// - - - - - - - -- - - - - - 
// and then about the inbetween/center points
// and the cross/diagonal angles
//
// the cross/diagonal line can be at various
// angle offsets to the vector,
// and its two (line) parts, going out from the 
// inbetween point can be of different
// lengths.
// 'normally' the the two parts are, each,
// half the length of the vector.
// this can be user adjusted

//  this indicates how far along the vector
//  in 'in between' point is located
float vector_inbtw_pt_loc_as_decimal_of_vector_length = 0.5;

// this is the angle of the line that goes from the 
// inbetween point. 
// angle zero means it has the same angle
// as the vector.
// any given angle here adds to the vector angle
float inbtw_cross_line_angle_degrees = 90;
float inbtw_cross_line_angle_radians = radians( inbtw_cross_line_angle_degrees );

// the length of the two parts of the 'crossing'/diagonal
// line
// if a value of 1.0 is given, the line segment is
// half the vector length. (such that the two
// half length vector parts add up to the vector length)
float inbtw_cross_line_first_part_line_length_decimal = 10.5 ;
float inbtw_cross_line_second_part_line_length_decimal = 10.5 ;



// - - - - - - - -- - - - - -   wind line movement ARRAYS
// this holds the regular line coords,
// as generated by the wind velocity and direction

// the key...
// make an array to hold the 'raw' weather data
String[] weather_data_lines ;

// the vector end points
float[] wind_location_coords_x;
float[] wind_location_coords_y;

// the inbetween points between the start/end of the vector
float[] wind_location_inbtw_pts_coords_x;
float[] wind_location_inbtw_pts_coords_y;

// the vector to the end of the FIRST part of the line going 
// from the centerpoint
float[] wind_location_inbtw_pt_cross_line_part_one_vector_x;
float[] wind_location_inbtw_pt_cross_line_part_one_vector_y;

// the vector to the end of the FIRST part of the line going 
// from the centerpoint
float[] wind_location_inbtw_pt_cross_line_part_two_vector_x;
float[] wind_location_inbtw_pt_cross_line_part_two_vector_y;

// --- visual time markup cross line mark arrays
//    these are as the above, but just with the fixed length of the 
//    cross line indicating time changes

// FIRST part
float[] dateNtime_visual_markup_cross_line_lengthOfOne_part_one_x;
float[] dateNtime_visual_markup_cross_line_lengthOfOne_part_one_y;

// SECOND part
float[] dateNtime_visual_markup_cross_line_lengthOfOne_part_two_x;
float[] dateNtime_visual_markup_cross_line_lengthOfOne_part_two_y;



// - -- - - - - - - - - - - - 
// and this holds the temperatures

float[] temperatures;



// - -- - - - - - - - - - - - 
// indicies to the weather data lines variables
// (i.e. where in each weather data line that we look for different info)

int raw_weather_data_average_timedate_index   = 0 ;
int raw_weather_data_average_wind_dir_index   = 2 ;
int raw_weather_data_average_wind_speed_index = 5 ;
int raw_weather_data_temperature_index = 9;




//  - - -- - - - - - - - - - - -  -
//
// keeps track of the current time/index we're 
// looking at in the weather data file

// and this is for the looping...
int curr_weather_index_starting_point = 0001;    // <---- THIS MIGHT WELL NOT BE USED!

// if we're restarting the drawing, from a random
// point in time, after a set amount of time has passed.
boolean restarting_drawing_after_given_time = false;
int max_individual_weather_session_length = 2160;

int curr_weather_data_index = curr_weather_index_starting_point;
int per_frame_curr_weather_data_index_incr = 1;
boolean paused_playback = false;

// fetch the current weather data line as a split string array
// we might as well fetch the current weather data line
// as a string, in the event we want to do some realtime feedbac
// of the current values
// String[] curr_weather_data_line_as_split_array;  // NOTE this is made redundant with the timestamps_array




// - - - -- - - - - - - - - - - -- -- - - - - - - - - - - - - - -- - - - - - - -





void setup(){

  size( stage_width , stage_height, OPENGL  );
  frameRate( 30 );


  // fetch a font for the text drawing
  el_font = loadFont("Courier-12.vlw");
  textFont(el_font, 14);



  // ----  fetch the data from the textfile, please


  weather_data_lines = loadStrings("data.csv");

  // quick weather feedback
  println( "weather data num of lines = "+weather_data_lines.length );

  ////   set up the array lengths (that hold the coordinate values)
  set_coord_n_dateNtime_array_lengths();


  ////   do the initial coordinate conversion - calculate all the relevant coordinates
  convert_wind_data_to_wind_coord_pts();



  ////    ----   set up the array with timestamps too ;-)  ... please   --- 
  //
  setup_timestamps_array();
  // feedback
  println(" \n just set up the timestamps array ... it's  got a length of "+timestamps_array.length );
  println(" \t the first line is "+timestamps_array[0]+", \n the middle line ( "+(timestamps_array.length/2)+" ) is "+timestamps_array[ timestamps_array.length/2 ]+" \n and the last line is "+timestamps_array[ timestamps_array.length-1 ]+"\n" );



  ////  ----  setup & find the date changes in the time --- 

  // setup the array which'll hold the position of the changes... 
  // it'll be the length of the time_stamps...
  dateNtime_changes_array = new int[ weather_data_lines.length ] ; 

  // find the time date changes 
  fetch_date_n_time_changes();



  ////   ---  set up the zoomed view  ---
  /* // input: Zoomed_view_draw( float zoomed_view_left_offset, float zoomed_view_right_offset, 
   float zoomed_view_screen_space_width, float zoomed_view_screen_space_height, 
   float zoomed_view_magnification_factor )
   */
  our_zoomed_view_draw = new Zoomed_view_draw( zoomed_view_screen_space_left_offset_x, zoomed_view_screen_space_top_offset_y,
  zoomed_view_width, zoomed_view_height, zoomed_view_magnification );


  ////    fill the array holding the temperatures, with values
  //       - well, only do it if we're using colour (test this below)
  if( doing_temperature_colouring_of_zoomed_in_wind_vector_line || doing_temperature_colouring_of_zoomed_in_cross_strokes || doing_temperature_colouring_of_nonzoomed_in_wind_vector_line ){
    setup_temperatures_array();
  }


  //     do a fill/stroke according to temperature test...
  set_stroke_or_fil_colour_acc_to_temp( "both", 10 );

}




// - - - - - -- - - - - - - - - - - - - - - - - - - - - - - -- - - - - - - - - -- -- 



void draw(){


  // for saving pdfs...
  if(saveOnePDFframe == true) {
    beginRecord(PDF, "Line####.pdf"); 
  }




  // empty the background
  background( background_colour );

  // -------------



  //// frame number feedback
  if( debug_b > 3 ){
    if( curr_weather_data_index % 100 == 0 ){
      println(" draw() curr_weather_data_index = "+curr_weather_data_index );
    }
  }



  // --------------  the drawing! 

  ////  draw the overall shape... maybe?
  if( drawing_all_pts_nonmagnified ){
    // our_draw_all.draw_all_points_up_to_current_weather_data_index();
    //// our_draw_all.draw_all_points_up_to_current_weather_data_index_offscreen();
    our_draw_all.draw_all_points_up_to_current_weather_data_index_in_vectors() ;
  }

  //// if we're drawing the zoomed in view
  if( drawing_zoomed_in_view ){
    our_zoomed_view_draw.draw_zoomed_view();
  }

  //// are we drawing the time?
  if( doing_timendate_drawing ){
    draw_timendate_from_timestamps_array();
  }


  // ----------------   for the next loop  -----------------

  // update the current weather data index position
  curr_weather_data_index += per_frame_curr_weather_data_index_incr;

  // remember to reset the frame count if "we've reached the end".
  if( curr_weather_data_index >= weather_data_lines.length-1 ){
    /// if( curr_weather_data_index >= wind_location_coords_x.length ){
    curr_weather_data_index = curr_weather_index_starting_point;
  }

  // if restarting from a random time-point, after a given interval
  if( restarting_drawing_after_given_time ){
    // - reset from random point!
    // check if we've shown more than the desired-at-once number of data points
    if( curr_weather_data_index > curr_weather_index_starting_point + max_individual_weather_session_length ){
      // wait a momdent - 0.2 seconds
      delay( 200 );

      // find a random moment in the weather index to restart things from
      curr_weather_data_index = int( random( weather_data_lines.length ) );

      // then restart things
      curr_weather_index_starting_point = curr_weather_data_index;
    }
  }




  ///// and save the frame being drawn!
  // Saves each frame as line-0000.png, line-0001.png, etc.
  if( save_frames ){
    saveFrame( saveFrame_filename ); 
  }



  // the final pdfs saving things...
  if(saveOnePDFframe == true) {
    endRecord();
    saveOnePDFframe = false; 
  }


}


// - - - -- - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - -- - 
// - - - -- - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - -- - 




/*
081208
 this function sets the lengths of the arrays.
 essentially it's the length of the weather data lines + 1
 
 even thought it might not make sense 
 with the non-vector-end-point coords (arrays),
 let's try have all the arrays the same length.
 
 for the inbetween points, pos [0] could be the starting point
 and the in between cross line [0] vectors could be zero (so they won't show up)
 */



void set_coord_n_dateNtime_array_lengths(){

  // fetch the 'guiding' array length
  int weather_data_lines_length_plus_one = weather_data_lines.length + 1;

  // set the array lengths


  //// the arrays holding the 'vector end' positions.
  // for every given wind dir+vel info, we'll calculate the end point
  // of the generated vector, from the previous position
  wind_location_coords_x = new float[ weather_data_lines_length_plus_one ];
  wind_location_coords_y = new float[ weather_data_lines_length_plus_one ];

  //// the inbetween points between the start/end of the vector
  wind_location_inbtw_pts_coords_x = new float[ weather_data_lines_length_plus_one ];
  wind_location_inbtw_pts_coords_y = new float[ weather_data_lines_length_plus_one ];

  //// cross line vectors
  // the vector to the end of the FIRST part of the line going 
  // from the centerpoint
  wind_location_inbtw_pt_cross_line_part_one_vector_x = new float[ weather_data_lines_length_plus_one ];
  wind_location_inbtw_pt_cross_line_part_one_vector_y = new float[ weather_data_lines_length_plus_one ];

  // the vector to the end of the FIRST part of the line going 
  // from the centerpoint
  wind_location_inbtw_pt_cross_line_part_two_vector_x = new float[ weather_data_lines_length_plus_one ];
  wind_location_inbtw_pt_cross_line_part_two_vector_y = new float[ weather_data_lines_length_plus_one ];

  //// and the same as above for the time change visual marks...?
  // FIRST part
  dateNtime_visual_markup_cross_line_lengthOfOne_part_one_x = new float[ weather_data_lines_length_plus_one ];
  dateNtime_visual_markup_cross_line_lengthOfOne_part_one_y = new float[ weather_data_lines_length_plus_one ];

  // SECOND part
  dateNtime_visual_markup_cross_line_lengthOfOne_part_two_x = new float[ weather_data_lines_length_plus_one ];
  dateNtime_visual_markup_cross_line_lengthOfOne_part_two_y = new float[ weather_data_lines_length_plus_one ];



}



// - - - -- - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - -- - 
// - - - -- - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - -- - 






/*

 090504
 variation on the function below, which sets the colour according
 to the temperature
 THIS ONE returns a colour value instead
 
 */


color fetch_colour_according_to_temp( float curr_temp ){


  // set up a temperature colour holder
  //  so it can be filled later
  color curr_temp_colour = color( 0 );



  // --------  find the relevant colour  -----
  //          i.e. check which part of the colour vs temp range
  //              the temperature is in, and set things accordingly


  // --  temp between -10 and 0 ?
  //
  // NOTE NOTE NOTE:  a bit of hacking on this first ( -10 >> -35 ) temp check
  if( ( curr_temp <= -10) && ( curr_temp > -30 ) ){
    // use the leftmost colour calues

    // colours
    color lower_temp_colour = color(  38, 129, 203 );  // 
    color higher_temp_colour = color( 146, 0, 149 );  // actually the lower temperature

    // define the current temperature range
    float curr_temp_start_range = -10 ;
    float curr_tempColor_zone_range = 20;
    // colour index for given range...
    // (we're foregoing the removal of the start of the range, as it's essentially zero... )
    // just remember to set up the colours right...
    float colour_blend_index_for_curr_tempColour_range = (abs( curr_temp )-abs( curr_temp_start_range ))/curr_tempColor_zone_range;

    // and finally find the right colour        
    curr_temp_colour = lerpColor( lower_temp_colour, higher_temp_colour, colour_blend_index_for_curr_tempColour_range );
  }
  if( ( curr_temp > -10) && ( curr_temp < 0 ) ){
    // use the leftmost colour calues

    // colours
    color lower_temp_colour = color( 202, 235, 250 );  // this is zero?
    color higher_temp_colour = color( 38, 129, 203 );

    // define the current temperature range
    float curr_temp_start_range = -10 ;
    float curr_tempColor_zone_range = 10;
    // colour index for given range...
    // (we're foregoing the removal of the start of the range, as it's essentially zero... )
    // just remember to set up the colours right...
    float colour_blend_index_for_curr_tempColour_range = abs( curr_temp )/curr_tempColor_zone_range;

    // and finally find the right colour        
    curr_temp_colour = lerpColor( lower_temp_colour, higher_temp_colour, colour_blend_index_for_curr_tempColour_range );
  }
  // --  between 0 and 8.2 ?  
  //
  if( ( curr_temp >= 0) && ( curr_temp < 8.2 ) ){
    // use the leftmost+1 colour calues

    // deinfe the colours for this temperature range
    color lower_temp_colour = color( 202, 235, 250 );  // this is zero?
    color higher_temp_colour = color( 200, 214, 197 );

    // define the temperature range (so we can get a decimal index for where this temp/colour should be)
    float curr_temp_start_range = 0 ;
    float curr_tempColor_zone_range = 8.2;

    //  a decimal index for where this temp/colour should be
    float colour_blend_index_for_curr_tempColour_range = curr_temp/curr_tempColor_zone_range ;

    // find the relevant colour
    curr_temp_colour = lerpColor( lower_temp_colour, higher_temp_colour, colour_blend_index_for_curr_tempColour_range );
  }

  // -- between 8.2 and 15.4
  //
  if( ( curr_temp >= 8.2) && ( curr_temp < 15.4 ) ){
    // use the leftmost+2 colour calues

    // colours
    color lower_temp_colour = color( 200, 214, 197 );
    color higher_temp_colour = color( 201, 197, 112 );

    // temp ranges
    float curr_temp_start_range = 8.2 ;
    float curr_tempColor_zone_range = 7.2 ;

    // find the decimal of where the current value is in that range
    float colour_blend_index_for_curr_tempColour_range = ( curr_temp-curr_temp_start_range )/curr_tempColor_zone_range ;

    // and finally find the right colour
    curr_temp_colour = lerpColor( lower_temp_colour, higher_temp_colour, colour_blend_index_for_curr_tempColour_range );
  }

  // -- between 15.4 and 37
  //
  if( ( curr_temp >= 15.4) && ( curr_temp < 37 ) ){
    // use the rightmost1 colour calues

    // the temperature range
    float curr_temp_start_range = 15.4 ;
    float curr_tempColor_zone_range = 20.6;

    // find the decimal of where the current value is in that range
    float colour_blend_index_for_curr_tempColour_range = abs( curr_temp-curr_temp_start_range )/curr_tempColor_zone_range ;

    // colours
    color lower_temp_colour = color( 201, 197, 112 );
    color higher_temp_colour = color( 243, 118, 90 );

    // and finally find the right colour
    curr_temp_colour = lerpColor( lower_temp_colour, higher_temp_colour, colour_blend_index_for_curr_tempColour_range );
  }


  // --- now we've got the colour, be nice and return it


  // now return something
  return curr_temp_colour;

} // end of rects loop


// - - - -- - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - -- - 
// - - - -- - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - -- - 




/*

 090504
 a function partly 'stolen' from / based on the valentine's blocks code,
 to set the fill or stroke colour according to the temperature
 (well, the colours are a little hardcoded into the code...
 but, well, changable still )
 
 */


void set_stroke_or_fil_colour_acc_to_temp( String set_fill_or_stroke_or_both, float curr_temp ){

  // set this temperature colour holder up so it can be filled later
  color curr_temp_colour = color( 0 );


  // --------  set the relevant colour  -----
  //          i.e. check which part of the colour vs temp range
  //              the temperature is in, and set things accordingly


  // between -30 and -10
  if( ( curr_temp > -30) && ( curr_temp <= -10 ) ){
    // use the leftmost colour calues

    // colours
    color lower_temp_colour = color( 38, 129, 203 );
    //  color higher_temp_colour = color( 135, 39, 201 );
    //  trying a deeper colour
    color higher_temp_colour = color( 93, 0, 160 );

    // define the current temperature range
    float curr_temp_start_range = -30 ;
    float curr_tempColor_zone_range = 21;
    // colour index for given range...
    // (we're foregoing the removal of the start of the range, as it's essentially zero... )
    // just remember to set up the colours right...
    float colour_blend_index_for_curr_tempColour_range = abs( curr_temp+11 )/curr_tempColor_zone_range;

    // and finally find the right colour        
    curr_temp_colour = lerpColor( lower_temp_colour, higher_temp_colour, colour_blend_index_for_curr_tempColour_range );

  }


  /* -- experimental version
   // between -30 and -10
   if( ( curr_temp > -30) && ( curr_temp <= -10 ) ){
   // use the leftmost colour calues
   
   // colours
   color lower_temp_colour = color( 38, 129, 203 );
   color higher_temp_colour = color( 135, 39, 201 );
   
   // define the current temperature range
   /// float curr_temp_start_range = -30 ;
   //    float curr_temp_start_range = -10 ; // 
   float curr_temp_start_range = 10 ; // testing with absolute numbers
   float curr_tempColor_zone_range = 21;  // well, adding +1 to try avoid off by 1  errors...
   // colour index for given range...
   // (we're foregoing the removal of the start of the range, as it's essentially zero... )
   // just remember to set up the colours right...
   float colour_blend_index_for_curr_tempColour_range = ( abs(curr_temp) - curr_temp_start_range )/curr_tempColor_zone_range;
   
   // and finally find the right colour        
   curr_temp_colour = lerpColor( lower_temp_colour, higher_temp_colour, colour_blend_index_for_curr_tempColour_range );
   }
   */

  // between -10 and 0
  if( ( curr_temp > -10) && ( curr_temp < 0 ) ){
    // use the leftmost colour calues

    // colours
    color lower_temp_colour = color( 240, 240, 255 );
    color higher_temp_colour = color( 38, 129, 203 );

    // define the current temperature range
    /// float curr_temp_start_range = -10 ;  not needed, starting at zero
    float curr_tempColor_zone_range = 11;   // well, adding +1 to try avoid off by 1  errors...
    // colour index for given range...
    // (we're foregoing the removal of the start of the range, as it's essentially zero... )
    // just remember to set up the colours right...
    float colour_blend_index_for_curr_tempColour_range = abs( curr_temp )/curr_tempColor_zone_range;

    // and finally find the right colour        
    curr_temp_colour = lerpColor( lower_temp_colour, higher_temp_colour, colour_blend_index_for_curr_tempColour_range );

  }
  // between 0 and 8.2
  if( ( curr_temp >= 0) && ( curr_temp < 8.2 ) ){
    // use the leftmost+1 colour calues

    // deinfe the colours for this temperature range
    color lower_temp_colour = color( 240, 240, 255 );
    color higher_temp_colour = color( 200, 214, 197 );

    // define the temperature range (so we can get a decimal index for where this temp/colour should be)
    float curr_temp_start_range = 0 ;
    float curr_tempColor_zone_range = 9.2; // off by one error fix

    //  a decimal index for where this temp/colour should be
    float colour_blend_index_for_curr_tempColour_range = curr_temp/curr_tempColor_zone_range ;

    // find the relevant colour
    curr_temp_colour = lerpColor( lower_temp_colour, higher_temp_colour, colour_blend_index_for_curr_tempColour_range );
  }

  // between 8.2 and 15.4
  if( ( curr_temp >= 8.2) && ( curr_temp < 15.4 ) ){
    // use the leftmost+2 colour calues

    // colours
    color lower_temp_colour = color( 200, 214, 197 );
    color higher_temp_colour = color( 201, 197, 112 );

    // temp ranges
    float curr_temp_start_range = 8.2 ;
    float curr_tempColor_zone_range = 8.2 ;  // off by one error fix

    // find the decimal of where the current value is in that range
    float colour_blend_index_for_curr_tempColour_range = ( curr_temp-curr_temp_start_range )/curr_tempColor_zone_range ;

    // and finally find the right colour
    curr_temp_colour = lerpColor( lower_temp_colour, higher_temp_colour, colour_blend_index_for_curr_tempColour_range );
  }

  // between 15.4 and 37
  if( ( curr_temp >= 15.4) && ( curr_temp < 37 ) ){
    // use the rightmost1 colour calues

    // the temperature range
    float curr_temp_start_range = 15.4 ;
    float curr_tempColor_zone_range = 21.6;

    // find the decimal of where the current value is in that range
    float colour_blend_index_for_curr_tempColour_range = abs( curr_temp-curr_temp_start_range )/curr_tempColor_zone_range ;

    // colours
    color lower_temp_colour = color( 201, 197, 112 );
    color higher_temp_colour = color( 243, 118, 90 );

    // and finally find the right colour
    curr_temp_colour = lerpColor( lower_temp_colour, higher_temp_colour, colour_blend_index_for_curr_tempColour_range );
  }


  // --- now we've got the colour, we set the fill or stroke as appropriate

    if( set_fill_or_stroke_or_both == "fill" ){
    fill( curr_temp_colour );
  } 
  else if( set_fill_or_stroke_or_both == "stroke" ){
    stroke( curr_temp_colour );
  }
  else if( set_fill_or_stroke_or_both == "both" ){
    fill( curr_temp_colour );
    stroke( curr_temp_colour );
  }


  //


} // end of rects loop





// - - - -- - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - -- - 
// - - - -- - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - -- - 







/*
090504
 a function that sets up the array holding the temperatures, properly
 the data can then be used elsewhere
 */

void setup_temperatures_array(){

  // fetch the 'guiding' array length
  // - we're setting it to the length of the weather data, plus one index,
  //   so we'll have it the same length as the weather data lines,
  //   and not go out of bounds, by accident, if we're following the
  //   same 'clock' as it is.
  int plus_one_temp_array_length = weather_data_lines.length + 1;

  // initialise/format the length of the array
  temperatures = new float[ plus_one_temp_array_length ];


  // loop and fill the array with values
  for( int i = 0; i < weather_data_lines.length; i++ ){

    // first, split the line from the text
    String[] current_weather_data_line_split = splitTokens( weather_data_lines[i], "," );

    // then fetch the relevant temperature value from split line and store it
    temperatures[i] = float( current_weather_data_line_split[ raw_weather_data_temperature_index ] );
  }

}








// - - - -- - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - -- - 
// - - - -- - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - -- - 



/*
function to fill the various
 coordinate and vector point arrays
 with relevant data
 
 */






void convert_wind_data_to_wind_coord_pts(){

  //// fetch the coord points, please
  // ASSIGN FIRST COORDS POINT to the official starting point ( which we've decided already )
  wind_location_coords_x[0] = start_point_x ;
  wind_location_coords_y[0] = start_point_y ;


  // and do the same for the inbetween points
  // (why, when the inbetween points are, by our definition, in between?
  //  because we want to use the same index to go through the array with...
  //  ... the first inbetween point being at the starting pos, is a small
  //      inconsistancy, compared to varying array position/indexes....below...
  wind_location_inbtw_pts_coords_x[0] = start_point_x ;
  wind_location_inbtw_pts_coords_y[0] = start_point_y ;

  // inbetween cross line vectors
  // - we don't need to set to the starting point, because they'll be '0' 
  //     by default, which means they'll be very small... and we don't need to worry about them


  // - - - - - - -  - - - - - - - - 
  //   now, please, calculate the line coords

  /* 
   loop through each of the 
   wind data lines and generate the relevant coordinate points
   
   // DON'T FORGET: we're setting the values at position n+1 - as the 
   //                first value is the starting point, which we didn't 
   //                get from the weather data
   */

  for( int i = 1; i < wind_location_coords_x.length ; i++ ){

    //// weather data fetch(ing)

    // fetch the line
    // SEPARATE the current LINE by TOKENS (i.e. commas ) into a String[] arrray
    // NOTE NOTE: the '-1' - this is because we've already filled the first position of the coords array with the
    //                user supplied starting point
    String[] current_weather_data_line_split = splitTokens( weather_data_lines[i-1], "," );

    // then EXTRACT THE VARIABLES the variables...
    float curr_wind_speed_in_ms = float( current_weather_data_line_split[ raw_weather_data_average_wind_speed_index ] ) ;
    float curr_wind_direction_in_radians = radians( float( current_weather_data_line_split[ raw_weather_data_average_wind_dir_index ] ) ) ;


    //// line position calculations

    // calculate the vector end position, formed by the wind speed and direction
    float curr_wind_dir_n_vel_vector_x = cos(curr_wind_direction_in_radians)*(curr_wind_speed_in_ms*wind_speed_one_meter_per_second_is_what_unit);
    // NOTE: the '-1' - it's because the vertical axis on a computer screen is inversed
    //            compared to paper - so we fix it with the '-1'
    float curr_wind_dir_n_vel_vector_y = -1*( sin(curr_wind_direction_in_radians)*(curr_wind_speed_in_ms*wind_speed_one_meter_per_second_is_what_unit) );

    // the (absolute) distance of the vector
    // (good for calculating the cross line)
    // - pythagorean formula... 
    float curr_wind_dir_n_vel_vector_abs_dist = sqrt( sq(curr_wind_dir_n_vel_vector_x)+ sq(curr_wind_dir_n_vel_vector_y) );


    // start by finding the vector end point 
    // (our 'starting point' is the previous location. then we add the vector created by the wind vel+rot )
    wind_location_coords_x[i] = wind_location_coords_x[i-1] + curr_wind_dir_n_vel_vector_x;
    wind_location_coords_y[i] = wind_location_coords_y[i-1] + curr_wind_dir_n_vel_vector_y;


    // calculate the 'point_in_between'
    // - the point between the start and end point of the vector
    //   - how far btw. the start&end points this point is, is given by the user
    wind_location_inbtw_pts_coords_x[i] = wind_location_coords_x[i-1] + (curr_wind_dir_n_vel_vector_x * vector_inbtw_pt_loc_as_decimal_of_vector_length);
    wind_location_inbtw_pts_coords_y[i] = wind_location_coords_y[i-1] + (curr_wind_dir_n_vel_vector_y * vector_inbtw_pt_loc_as_decimal_of_vector_length);


    // then the feedback for this part
    if( debug > 4 ){
      println(" \n weather tracing gen coords + vectors from wind data here... \n\t working on weather data line "+i+" \n\t the current received wind speed and direction(radians) is "+curr_wind_speed_in_ms+", "+curr_wind_direction_in_radians );
      println(" \t wind_location_inbtw_pts_coords_x/y = "+wind_location_inbtw_pts_coords_x[i]+", "+wind_location_inbtw_pts_coords_y[i] );
      println(" \t curr_wind_dir_n_vel_vector_x, curr_wind_dir_n_vel_vector_y = "+curr_wind_dir_n_vel_vector_x+", "+curr_wind_dir_n_vel_vector_y );
      println(" \t curr_wind_dir_n_vel_vector_abs_dist = "+curr_wind_dir_n_vel_vector_abs_dist );
      println(" \t wind_location_inbtw_pts_coords_x/y = "+wind_location_inbtw_pts_coords_x[i]+", "+wind_location_inbtw_pts_coords_y[i] );
    }



    // find the vectors to the start / end points of the 'cross' / diagonal lines
    // - their length can be varied, and the lengths relate
    // to the absolute distance of the wind dir+vel vector (calculated at the start here)

    // first, calculate half the abs wind vector distance 
    // (if the user suggests the length of a line vector is 1.0,
    //  then for the two bits to add up to the abs wind vel+rot vector, 
    // they must each be half (i.e. 0.5+0.5 = 1.0)
    float half_curr_wind_dir_n_vel_vector_abs_dist = curr_wind_dir_n_vel_vector_abs_dist / 2.0;

    // then we must find the angles of the two lines.. 
    // first part angle = vector angle + cross line angle offset in radians
    // second part angle = (vector angle+180°) + cross line angle offset in radians
    // ( PI = 180° )
    float cross_line_part_one_angle_in_radians = curr_wind_direction_in_radians + inbtw_cross_line_angle_radians;
    float cross_line_part_two_angle_in_radians = (curr_wind_direction_in_radians+PI) + inbtw_cross_line_angle_radians;

    // the length of one unit... in the direction of the cross line angle
    // (doing it this way so we don't have to do it twice...)
    // - line part one
    float wind_location_in_btw_pt_cross_line_part_one_length_of_one_x = cos(cross_line_part_one_angle_in_radians) ;
    float wind_location_in_btw_pt_cross_line_part_one_length_of_one_y = -1*sin(cross_line_part_one_angle_in_radians) ;
    // - line part two
    float wind_location_in_btw_pt_cross_line_part_two_length_of_one_x = cos(cross_line_part_two_angle_in_radians) ;
    float wind_location_in_btw_pt_cross_line_part_two_length_of_one_y = -1*sin(cross_line_part_two_angle_in_radians) ;



    // then, finally, find the vectors to the ends of the cross line
    // - part one
    wind_location_inbtw_pt_cross_line_part_one_vector_x[i] = wind_location_in_btw_pt_cross_line_part_one_length_of_one_x * (half_curr_wind_dir_n_vel_vector_abs_dist * inbtw_cross_line_first_part_line_length_decimal) ;
    // '-1*' = axes flip fox - the computer screen vertical axis is inversed compared to paper
    wind_location_inbtw_pt_cross_line_part_one_vector_y[i] = wind_location_in_btw_pt_cross_line_part_one_length_of_one_y * (half_curr_wind_dir_n_vel_vector_abs_dist * inbtw_cross_line_first_part_line_length_decimal) ;

    // - part two
    wind_location_inbtw_pt_cross_line_part_two_vector_x[i] = wind_location_in_btw_pt_cross_line_part_two_length_of_one_x * (half_curr_wind_dir_n_vel_vector_abs_dist * inbtw_cross_line_second_part_line_length_decimal) ;
    // '-1*' = axes flip fox - the computer screen vertical axis is inversed compared to paper
    wind_location_inbtw_pt_cross_line_part_two_vector_y[i] = wind_location_in_btw_pt_cross_line_part_two_length_of_one_y * (half_curr_wind_dir_n_vel_vector_abs_dist * inbtw_cross_line_second_part_line_length_decimal ) ;


    // more feedback
    if( debug > 4 ){
      println(" and... \n\t half_curr_wind_dir_n_vel_vector_abs_dist = "+half_curr_wind_dir_n_vel_vector_abs_dist+" \n\t cross_line_part_one_angle_in_radians, cross_line_part_two_angle_in_radians = "+cross_line_part_one_angle_in_radians+", "+cross_line_part_two_angle_in_radians );
      println("\t wind_location_inbtw_pt_cross_line_part_one_vector_x/y = "+wind_location_inbtw_pt_cross_line_part_one_vector_x[i]+", "+wind_location_inbtw_pt_cross_line_part_one_vector_y[i] );
      println("\t wind_location_inbtw_pt_cross_line_part_two_vector_x/y = "+wind_location_inbtw_pt_cross_line_part_two_vector_x[i]+", "+wind_location_inbtw_pt_cross_line_part_two_vector_y[i] );
    }




    // FIRST part 
    dateNtime_visual_markup_cross_line_lengthOfOne_part_one_x[i] = wind_location_in_btw_pt_cross_line_part_one_length_of_one_x * visual_time_change_markup_cross_stroke_length ;
    dateNtime_visual_markup_cross_line_lengthOfOne_part_one_y[i] = wind_location_in_btw_pt_cross_line_part_one_length_of_one_y * visual_time_change_markup_cross_stroke_length ;

    // SECOND part
    dateNtime_visual_markup_cross_line_lengthOfOne_part_two_x[i] = wind_location_in_btw_pt_cross_line_part_two_length_of_one_x * visual_time_change_markup_cross_stroke_length ;
    dateNtime_visual_markup_cross_line_lengthOfOne_part_two_y[i] = wind_location_in_btw_pt_cross_line_part_two_length_of_one_y * visual_time_change_markup_cross_stroke_length ;


  }
}




// - - - -- - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - -- - 
// - - - -- - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - -- - 





/*
a function that sets up a String array to hold the timestamps
 */


void setup_timestamps_array() {

  // set up the right length
  timestamps_array = new String[ weather_data_lines.length ] ;

  // loop and copy
  for( int i = 0; i < weather_data_lines.length; i++ ){

    timestamps_array[i] = splitTokens( weather_data_lines[i] , "," )[raw_weather_data_average_timedate_index];

  }
}




// - - - -- - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - -- - 
// - - - -- - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - -- - 

// 090616

//     alternate version of the function below
//       - this one uses the timestamps_array...

void draw_timendate_from_timestamps_array(){

  // fetch the relevant time data
  String curr_time_n_date = timestamps_array[ curr_weather_data_index ] ;
  // println(" curr_time_n_date = "+curr_time_n_date );
  // set the fill as appropriate
  fill( time_colour );
  text( curr_time_n_date, time_left_offset_x, time_top_offset_y );
  // and then set to no fill
  noFill();

}



// - - - -- - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - -- - 
// - - - -- - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - -- - 




// various functions 'caused' by keypresses 

void keyPressed(){

  // // zoom...
  if( key == '1'){
    our_zoomed_view_draw.our_zoomed_view_magnification_factor -= 0.1;
    println(" the zoomed view magnification is now "+our_zoomed_view_draw.our_zoomed_view_magnification_factor );
  }
  if( key == '2'){
    our_zoomed_view_draw.our_zoomed_view_magnification_factor += 0.1;
    println(" the zoomed view magnification is now "+our_zoomed_view_draw.our_zoomed_view_magnification_factor );
  }

  // // christmas colours?
  // center stroke
  if( key == 'c' ){
    doing_christmas_zoomed_centerline_stroke_colours = !doing_christmas_zoomed_centerline_stroke_colours;
    println(" doing_christmas_zoomed_centerline_stroke_colours is.. "+doing_christmas_zoomed_centerline_stroke_colours );
  }
  // cross lines
  if( key == 'x' ){
    doing_christmas_zoomed_cross_lines_colours = !doing_christmas_zoomed_cross_lines_colours;
    println(" doing_christmas_zoomed_cross_lines_colours is.. "+doing_christmas_zoomed_cross_lines_colours );
  }


  // // drwaing the time?
  if( key == 't' ){
    doing_timendate_drawing = !doing_timendate_drawing;
  }

  // // drwaing the time MARKS?
  if( key == 'm' ){
    drawing_visual_time_indications = !drawing_visual_time_indications ;
  }


  // -- moving forward or backward in time?
  if( key == ']' ){
    curr_weather_data_index += 288 * 7 ; // a week++ 
  }
  if( key == '[' ){
    curr_weather_data_index -= 288 * 7 ; // a week-- 
  }



  // -----------

  /*
NOTE
   NOTE 
   NOTE
   NOTE     VERY SPECIAL INTERESTING HELSINKI MODIFICATION - jumps to the 17th....
   NOTE
   NOTE
   */

  // cross lines
  if( key == '5' ){
    // clear the screen
    fill( 255, 32 );
    rect( 0, 0, width, height );
    // jump to the new start point
    curr_weather_data_index = 124884 ;
  }

  // ----



  // playback speed ...
  if (key == CODED) {
    // this is for pausing the playback
    if (keyCode == SHIFT) {
      paused_playback = !paused_playback;
      if( paused_playback == false ){
        noLoop(); 
      }
      else {
        loop();
      }
    }
    // this is for reversing the playback speed to go negative/backwards
    if( keyCode == LEFT ){
      per_frame_curr_weather_data_index_incr = -1;
    }
    // and this is for making the playback speed go forwards (again)
    if( keyCode == RIGHT ){
      per_frame_curr_weather_data_index_incr = 1;
    }
  }



  // ---- 

  // saving a frame?
  // .. .press 's'
  if( key == 's' ){
    saveOnePDFframe = true;    
  }



  // // and a completely different drawing mode?



}

// - - - -- - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - -- - 

// - - - -- - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - -- - 

/* - we're disabling this for the time being...
 
 // more pdf saving things...
 void mousePressed() {
 saveOnePDFframe = true; 
 }
 
 */


// - - - -- - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - -- - 













