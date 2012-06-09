/*

 this class handles the drawing of the zoomed in view
 
 paramters:
 
 float magnified_view_screen_left_offset
 float magnified_view_screen_space_top_offset
 
 float magnified_view_screen_space_width
 float magnified_view_screen_space_height
 
 float zoomed_view_magnification_factor
 
 
 */



class Zoomed_view_draw{


  // // instantiations


  // values from the parameters

  // left and top offset
  float our_zoomed_view_screen_space_left_offset;
  float our_zoomed_view_screen_space_top_offset;

  float our_zoomed_view_screen_space_half_width;
  float our_zoomed_view_screen_space_half_height;
  // these are generated from the above
  // using the magnification factor, we figure this out
  // (the values below = (values above * 0.5)/magnification_factor
  float our_zoomed_view_screen_space_magnified_HALF_width;
  float our_zoomed_view_screen_space_magnified_HALF_height;

  // how much bigger than 1:1 scale the zoomed in view is supposed to be
  float our_zoomed_view_magnification_factor;



  ////// then the values that we generate 'on the fly'
  // 

  //// wind vector points

  // these are the borders of the magnified view, in wind coord space
  // (these values are used for finding which coords are 
  //  'inside' the current view )
  // left
  float our_zoomed_view_wind_coord_space_magnified_left_x;
  // top
  float our_zoomed_view_wind_coord_space_magnified_top_y;  
  // right
  float our_zoomed_view_wind_coord_space_magnified_right_x;
  // bottom
  float our_zoomed_view_wind_coord_space_magnified_bottom_y;



  // one wind coord space position
  // (it'll be used often, so it's worth it)
  float curr_wind_location_coord_space_pt_x;
  float curr_wind_location_coord_space_pt_y;


  //// then the absolute positions

  // wind vector positions
  float curr_wind_vector_pt_abs_x;
  float curr_wind_vector_pt_abs_y;
  // the previous point
  float prev_wind_vector_pt_abs_x;
  float prev_wind_vector_pt_abs_y;


  // the in-between-point
  float curr_in_btw_pt_abs_x;
  float curr_in_btw_pt_abs_y;

  // the in-between-point-line endings...
  float curr_cross_line_part_one_end_x;
  float curr_cross_line_part_one_end_y;  
  // and the second part
  float curr_cross_line_part_two_end_x;
  float curr_cross_line_part_two_end_y;  


  // and this stores the temperature, if needed...
  color curr_temp_colour;



  // // constructor

    Zoomed_view_draw( float zoomed_view_left_offset, float zoomed_view_right_offset, 
  float zoomed_view_screen_space_width, float zoomed_view_screen_space_height, 
  float zoomed_view_magnification_factor ){


    // left and top offset
    our_zoomed_view_screen_space_left_offset = zoomed_view_left_offset;
    our_zoomed_view_screen_space_top_offset = zoomed_view_right_offset;

    our_zoomed_view_screen_space_half_width = zoomed_view_screen_space_width/2.0 ;
    our_zoomed_view_screen_space_half_height = zoomed_view_screen_space_height/2.0 ;
    // these are generated from the above
    // using the magnification factor, we figure this out
    // (the values below = (values above * 0.5)/magnification_factor
    our_zoomed_view_screen_space_magnified_HALF_width = our_zoomed_view_screen_space_half_width / zoomed_view_magnification_factor;
    our_zoomed_view_screen_space_magnified_HALF_height = our_zoomed_view_screen_space_half_height / zoomed_view_magnification_factor ;

    // how much bigger than 1:1 scale the zoomed in view is supposed to be
    our_zoomed_view_magnification_factor = zoomed_view_magnification_factor ;


    // feeble feedback 
    println(" aaahhh ! we're got a zoomed view draw set up! \n\t our_zoomed_view_screen_space_left/top_offset = "+our_zoomed_view_screen_space_left_offset+", "+our_zoomed_view_screen_space_top_offset);
    println(" \t our_zoomed_view_screen_space_half_width/height = "+our_zoomed_view_screen_space_half_width+", "+our_zoomed_view_screen_space_half_height );
    println(" \t our_zoomed_view_screen_space_magnified_HALF_width/height = "+our_zoomed_view_screen_space_magnified_HALF_width+", "+our_zoomed_view_screen_space_magnified_HALF_height );
  }


  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  -
  //
  // various methods
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  -



  /*
  081209
   function to draw the zoomed view
   
   now?
   
   - fetch the current weather data loc
   - figure out the magnified view's left|top|right|bottom
   - loop, find each point 'inside'.
   - for each point inside:
   - find the current and previous wind vector loc... in abs coord terms (dont' worry about the offsets)
   - draw the vector start/end line
   
   - find the inbetween point + cross line vectors... in abs coord terms (w/o left/top offsets)
   - draw the cross line
   
   */


  void draw_zoomed_view(){


    // // // find the magnified view bounds, in winds coord space

    // start by finding the current centre of the magnified view
    curr_wind_location_coord_space_pt_x = wind_location_coords_x[ curr_weather_data_index ] ;
    curr_wind_location_coord_space_pt_y = wind_location_coords_y[ curr_weather_data_index ] ;    

    // find the magnified view bounds (left|top|right|bottom) in winds space coord terms
    // left
    our_zoomed_view_wind_coord_space_magnified_left_x = curr_wind_location_coord_space_pt_x - our_zoomed_view_screen_space_magnified_HALF_width;
    // top
    our_zoomed_view_wind_coord_space_magnified_top_y = curr_wind_location_coord_space_pt_y - our_zoomed_view_screen_space_magnified_HALF_height;  
    // right
    our_zoomed_view_wind_coord_space_magnified_right_x = curr_wind_location_coord_space_pt_x + our_zoomed_view_screen_space_magnified_HALF_width;
    // bottom
    our_zoomed_view_wind_coord_space_magnified_bottom_y = curr_wind_location_coord_space_pt_y + our_zoomed_view_screen_space_magnified_HALF_height;

    // more feeble feedback
    if( debug_b > 4 ){
      println(" draw_zoomed_view(): \n\t \n\t  curr_wind_location_coord_space_pt_x/y = "+ curr_wind_location_coord_space_pt_x+", "+ curr_wind_location_coord_space_pt_y );
      println(" \t our_zoomed_view_wind_coord_space_magnified_left/top_x/y = "+our_zoomed_view_wind_coord_space_magnified_left_x+", "+our_zoomed_view_wind_coord_space_magnified_top_y );
      println(" \t our_zoomed_view_wind_coord_space_magnified_right/bottom_x/y = "+our_zoomed_view_wind_coord_space_magnified_right_x+", "+our_zoomed_view_wind_coord_space_magnified_bottom_y );
      println(" \t our_zoomed_view_screen_space_left/top_offset = "+our_zoomed_view_screen_space_left_offset+", "+our_zoomed_view_screen_space_top_offset );
    }
    // // //  draw the points inside the zoomed view


    // start by moving the origin to the left|top offset of the zoomed view
    // store the origin...
    pushMatrix();
    // now move
    translate( our_zoomed_view_screen_space_left_offset, our_zoomed_view_screen_space_top_offset );


    // first, find the points are inside
    // (loop from the start to the current point index
    // (so you don't draw 'the future' ))
    // ERRR: well, start at 1 - as you're drawing points 
    //        from the previous to the current index
    for( int curr_pt_i = 1; curr_pt_i <= curr_weather_data_index; curr_pt_i++ ){

      // fetch the wind current cector coords 
      curr_wind_location_coord_space_pt_x = wind_location_coords_x[curr_pt_i];
      curr_wind_location_coord_space_pt_y = wind_location_coords_y[curr_pt_i];

      // feedback
      if( debug_b > 4 ){
        println(" \t working on pt "+curr_weather_data_index+" - ( "+curr_wind_location_coord_space_pt_x+", "+curr_wind_location_coord_space_pt_y+" )" );
      }



      // check if the point is inside
      if( is_curr_wind_vector_pt_is_inside() ){


        // if we're colouring according to temperature...        
        // save the temperature if we're colouring any of the zoomed in components 
        // according to the temperature
        if( doing_temperature_colouring_of_zoomed_in_wind_vector_line || doing_temperature_colouring_of_zoomed_in_cross_strokes ){
          // find the relevant "temperature colour"
          curr_temp_colour = fetch_colour_according_to_temp( temperatures[curr_pt_i]-1 );
        }


        // if we're drawing the wind vector points...
        if( drawing_zoomed_in_view_weather_vector_pts ){

          // might as well fetch the previous coords too... as we'll be using them
          // i.e. note the "curr_pt_i-1"
          float prev_wind_vector_coord_space_pt_x = wind_location_coords_x[curr_pt_i-1];
          float prev_wind_vector_coord_space_pt_y = wind_location_coords_y[curr_pt_i-1];

          // convert the wind vector coords from wind coordinate space
          // to screen coordinate space (well, without the left/top offsets
          curr_wind_vector_pt_abs_x = calculate_abs_zoomed_coords( curr_wind_location_coord_space_pt_x, "x");
          curr_wind_vector_pt_abs_y = calculate_abs_zoomed_coords( curr_wind_location_coord_space_pt_y, "y");

          prev_wind_vector_pt_abs_x = calculate_abs_zoomed_coords( prev_wind_vector_coord_space_pt_x, "x");
          prev_wind_vector_pt_abs_y = calculate_abs_zoomed_coords( prev_wind_vector_coord_space_pt_y, "y");

          // feedback
          if( debug_b > 4 ){
            println(" \t drawing_zoomed_in_view_weather_vector_pts - \n\t prev_wind_vector_coord_space_pt_x/y = "+prev_wind_vector_coord_space_pt_x+", "+prev_wind_vector_coord_space_pt_y );
            println(" \t\t curr_wind_vector_pt_abs_x /y "+curr_wind_vector_pt_abs_x+", "+curr_wind_vector_pt_abs_y+" | prev_wind_vector_pt_abs_x/y = "+prev_wind_vector_pt_abs_x+", "+prev_wind_vector_pt_abs_y );
          }


          // draw please!

          // if we're doing the CHRISTMAS COLOURS
          // ... do this: the way we're fetching the index should guarantee
          //      that each cross section maintains its own colour
          if( doing_christmas_zoomed_centerline_stroke_colours ){
            int centerline_stroke_colour_index = ( curr_weather_data_index*christmas_colours.length - curr_pt_i ) % christmas_colours.length ;
            stroke( christmas_colours[centerline_stroke_colour_index] );
          }
          // if we're colouring the centerline according to temperature
          else if( doing_temperature_colouring_of_zoomed_in_wind_vector_line ){
            // set the stroke as appropriate...
            stroke( curr_temp_colour, temperature_coloured_zoomed_in_wind_vector_line_transparency );
          }
          else{
            // stroke 'normallly', if all else is undesired
            stroke( zoomed_in_line_general_weather_coords_stroke_colour );
          }
          
          // and the same stroke weight should apply to all the colourings
          strokeWeight( zoomed_in_line_general_weather_coords_stroke_width );

          // then draw something!
          line( prev_wind_vector_pt_abs_x, prev_wind_vector_pt_abs_y, curr_wind_vector_pt_abs_x, curr_wind_vector_pt_abs_y );
        }


        // ------   drawing the in between point cross lines???



        if( drawing_zoomed_in_view_cross_lines ){

          // // fetch the relevant coordinates and vectors

            // in between points
          float curr_in_btw_pt_x = wind_location_inbtw_pts_coords_x[ curr_pt_i ];
          float curr_in_btw_pt_y = wind_location_inbtw_pts_coords_y[ curr_pt_i ];

          // calculate the line endings for the cross line
          // cross line part one
          float curr_cross_line_part_one_line_end_x = curr_in_btw_pt_x + wind_location_inbtw_pt_cross_line_part_one_vector_x[curr_pt_i] ;
          float curr_cross_line_part_one_line_end_y = curr_in_btw_pt_y + wind_location_inbtw_pt_cross_line_part_one_vector_y[curr_pt_i] ;
          // cross line part two
          float curr_cross_line_part_two_line_end_x = curr_in_btw_pt_x + wind_location_inbtw_pt_cross_line_part_two_vector_x[curr_pt_i] ;
          float curr_cross_line_part_two_line_end_y = curr_in_btw_pt_y + wind_location_inbtw_pt_cross_line_part_two_vector_y[curr_pt_i] ;


          // ------  convert the coordinates to screen/absolute space

          // in between center points
          curr_in_btw_pt_x = calculate_abs_zoomed_coords( curr_in_btw_pt_x, "x" ) ;
          curr_in_btw_pt_y = calculate_abs_zoomed_coords( curr_in_btw_pt_y, "y" ) ;

          // cross line end points
          // part one
          curr_cross_line_part_one_line_end_x = calculate_abs_zoomed_coords( curr_cross_line_part_one_line_end_x, "x") ;
          curr_cross_line_part_one_line_end_y = calculate_abs_zoomed_coords( curr_cross_line_part_one_line_end_y, "y") ;
          // part two
          curr_cross_line_part_two_line_end_x = calculate_abs_zoomed_coords( curr_cross_line_part_two_line_end_x, "x") ;
          curr_cross_line_part_two_line_end_y = calculate_abs_zoomed_coords( curr_cross_line_part_two_line_end_y, "y") ;


          // ------

          // set the stroke colour and weight

          // doing the christmas colours ????
          //
          // ... do this: the way we're fetching the index should guarantee
          //      that each cross section maintains its own colour
          if( doing_christmas_zoomed_cross_lines_colours ){
            // int cross_stroke_colour_index = ( curr_weather_data_index + curr_pt_i + 1 ) % christmas_colours.length ;
            int cross_stroke_colour_index = ( curr_weather_data_index*christmas_colours.length - curr_pt_i ) % christmas_colours.length ;
            stroke( christmas_colours[cross_stroke_colour_index] );
          }
          // and if we're colouring things according to the temperature
          else if( doing_temperature_colouring_of_zoomed_in_cross_strokes ) {
            stroke( curr_temp_colour, temperature_coloured_zoomed_in_main_cross_stroke_transparency );
          }
          else{ // do the normal colurs
            stroke( zoomed_in_line_cross_line_stroke_color );
          }

          strokeWeight( zoomed_in_line_cross_line_stroke_weight );
          
          /* -- trying to draw both parts in one go 
          // line part one
          line( curr_in_btw_pt_x, curr_in_btw_pt_y, curr_cross_line_part_one_line_end_x, curr_cross_line_part_one_line_end_y  );
          // line part two
          line( curr_in_btw_pt_x, curr_in_btw_pt_y, curr_cross_line_part_two_line_end_x, curr_cross_line_part_two_line_end_y );
          */
          // line part one
          line( curr_cross_line_part_one_line_end_x, curr_cross_line_part_one_line_end_y, curr_cross_line_part_two_line_end_x, curr_cross_line_part_two_line_end_y  );
        }




        //    ---    indication marks/cross lines??? ----



        // this is if we're doing those big cross strokes 
        // indicating 
        if( drawing_visual_time_indications ){

          // and here we check if we should draw a time indication
          // i.e. that there's such a time change that it warrants a time change indicator
          if(  dateNtime_changes_array[curr_pt_i] >= timedate_change_markup_threshold  ){

            // in between points
            float curr_in_btw_pt_x = wind_location_inbtw_pts_coords_x[ curr_pt_i ];
            float curr_in_btw_pt_y = wind_location_inbtw_pts_coords_y[ curr_pt_i ];

            // calculate the line endings for the cross line
            // cross line part one
            float curr_time_indication_line_part_one_end_x = curr_in_btw_pt_x + dateNtime_visual_markup_cross_line_lengthOfOne_part_one_x[curr_pt_i] ;
            float curr_time_indication_line_part_one_end_y = curr_in_btw_pt_y + dateNtime_visual_markup_cross_line_lengthOfOne_part_one_y[curr_pt_i] ;
            // cross line part two
            float curr_time_indication_line_part_two_end_x = curr_in_btw_pt_x + dateNtime_visual_markup_cross_line_lengthOfOne_part_two_x[curr_pt_i] ;
            float curr_time_indication_line_part_two_end_y = curr_in_btw_pt_y + dateNtime_visual_markup_cross_line_lengthOfOne_part_two_y[curr_pt_i] ;


            // ------  convert the coordinates to screen/absolute space

            // NOTE
            // NOTE  - yes, we calculated this in the cross line drawing above
            // NOTE  -    but maybe for some strange reason, the user isn't drawing the cross strokes...
            // NOTE  -    so the value might not have been calculated... in which case we do it again here.. .just in case
            // NOTE
            // in between center points
            curr_in_btw_pt_x = calculate_abs_zoomed_coords( curr_in_btw_pt_x, "x" ) ;
            curr_in_btw_pt_y = calculate_abs_zoomed_coords( curr_in_btw_pt_y, "y" ) ;

            // cross line end points
            // part one
            curr_time_indication_line_part_one_end_x = calculate_abs_zoomed_coords( curr_time_indication_line_part_one_end_x, "x") ;
            curr_time_indication_line_part_one_end_y = calculate_abs_zoomed_coords( curr_time_indication_line_part_one_end_y, "y") ;
            // part two
            curr_time_indication_line_part_two_end_x = calculate_abs_zoomed_coords( curr_time_indication_line_part_two_end_x, "x") ;
            curr_time_indication_line_part_two_end_y = calculate_abs_zoomed_coords( curr_time_indication_line_part_two_end_y, "y") ;



            // ----   set the colours as appropriate

            // stroke
            //// filler value
            stroke( time_indic_vis_colour );
            // stroke weight
            strokeWeight( time_indic_vis_stroke_strokeWeight );

            // ----   finally, do some drawing


            // line part one
            line( curr_in_btw_pt_x, curr_in_btw_pt_y, curr_time_indication_line_part_one_end_x, curr_time_indication_line_part_one_end_y  );
            // line part two
            line( curr_in_btw_pt_x, curr_in_btw_pt_y, curr_time_indication_line_part_two_end_x, curr_time_indication_line_part_two_end_y );

          }
        } // end of drawing visual time indicators bits...
      }
    }
    // reset the drawing matrix
    popMatrix();
  }


  // - -- - - - - - - 



  // a function that checks whether the given point, of the wind vector coords, 
  //   is inside the magnified view bounding box

    boolean is_curr_wind_vector_pt_is_inside(){

    // this value indicates whether the given coord is inside
    // the zoomed window bounds (in weather coords space)
    boolean isinside = false;

    // if it's inside, we change the isinside value
    // otherwise - if the point is not inside - it'll just be false
    if( curr_wind_location_coord_space_pt_x > our_zoomed_view_wind_coord_space_magnified_left_x && curr_wind_location_coord_space_pt_x < our_zoomed_view_wind_coord_space_magnified_right_x && curr_wind_location_coord_space_pt_y > our_zoomed_view_wind_coord_space_magnified_top_y && curr_wind_location_coord_space_pt_y < our_zoomed_view_wind_coord_space_magnified_bottom_y ) {
      isinside = true;
    }

    // then return something nice
    return isinside;  
  }




  // - -- - - - - - - 

  /*
   a function which converts a wind coordinate space coord 
   into a screen space abs coord (well, except for the offset )
   */


  float calculate_abs_zoomed_coords( float wind_coordinate_space_coord, String x_or_y_axis ){

    // have somewhere to store the result
    float converted_coord = 0;

    // // fix the offset
    // if the coordinate is on the x-axis....
    if( x_or_y_axis == "x" ){
      // subtract the left zoomed view offset
      converted_coord = wind_coordinate_space_coord - our_zoomed_view_wind_coord_space_magnified_left_x;  
    } // and if we're dealign with something on the y axis...
    else if(  x_or_y_axis == "y" ){
      // subtract the top zoomed view offset
      converted_coord = wind_coordinate_space_coord - our_zoomed_view_wind_coord_space_magnified_top_y;
    }

    // // multiply by the magnification factor  
    // goes for both axes
    converted_coord *= our_zoomed_view_magnification_factor;

    if( debug_b > 5 ){
      println(" calculate_abs_zoomed_coords() \t \n\t received "+x_or_y_axis+" coord was "+wind_coordinate_space_coord+" generated coord = "+converted_coord );
    }

    // - -
    // and then return something nice...
    return converted_coord;

  }



  // class ends here ...
}



















