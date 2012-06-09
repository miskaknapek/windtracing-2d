/*

 this class draws the unmagnified line,
 straight from the different arrays we've set up.
 
 */


class Draw_all{


  // - - -- - - - - - - 
  //
  // initialisations


  // ---- some values for the offscreen drawing

  // these coords store the offset value
  // that's added to the 'raw coords' 
  // so they happen inside the screen

  float coords_offset_x = 0;
  float coords_offset_y = 0;


  // wind_vectors_start_index 
  // for the small nonscaled line darwing
  // suggests from which point in the data
  // to draw the nonscaled line.
  // (this value gets reset when the line goes outside the screen area )
  // (at the same time the offsets get changed so the line
  //   is inside the screen again ).
  int wind_vectors_start_index = 1;
  
  
  
  // this holds the calculated colour for the given temperature
  // (used several times, good to keep)
  color curr_temp_colour;




  // - - -- - - - - - - - 
  //
  // constructor







  // -===================================
  //
  // methods
  //






  // ----------------------------------

  // this is a modified version of the function below,
  // drawing the small line.. [offscreen]

  void draw_all_points_up_to_current_weather_data_index_in_vectors(){



    // ------ draw from the previous coord value to the current one



    // -- find the 'in-screen' offset coordinates
    // using the offset values to generate an onscreen
    // value for the 'raw' windcoords

      // new version for the onscreen drawing
    float curr_lineEnd_x = wind_location_coords_x[curr_weather_data_index] + coords_offset_x ;
    float curr_lineEnd_y = wind_location_coords_y[curr_weather_data_index] + coords_offset_y ;

    // --- ok, the following doesn't quite work, 
    // I think it could be due to resetting both x/y offsets if just one of the
    // values goes offscreen... so let's try doing it in two steps...
    //  ... one for x and one for y

      // ---- then check if the coords are inside, 
    // and if they're not, then we fix things for the next loop
    if( ( curr_lineEnd_x > stage_width || curr_lineEnd_x < 0 ) || 
      ( curr_lineEnd_y > stage_height || curr_lineEnd_y < 0 ) ){

      /// - not needed, as we're draing straight onto the screen
      // blank out the offscreen draw area
      ////fill( background_colour );
      ////rect( 0, 0, stage_width, stage_height );


      // find out the new screen offsets

      //// coords_offset_x = start_point_x - wind_location_coords_x[curr_weather_data_index];
      //// coords_offset_y = start_point_y - wind_location_coords_y[curr_weather_data_index];    

      // try this instead      
      coords_offset_x = -1*( wind_location_coords_x[curr_weather_data_index] - start_point_x ) ;
      coords_offset_y = -1*( wind_location_coords_y[curr_weather_data_index] - start_point_y ) ;    

      // then reset the index, from
      // which the unscaled line darwing starts
      wind_vectors_start_index = curr_weather_data_index;


      if( backg_line_debug > 3 ){
        println(" \n background line drawing - looks like the background line just went offscreen..." );
        println(" \t at index = "+curr_weather_data_index+", real wind loc coords "+wind_location_coords_x[curr_weather_data_index]+", "+wind_location_coords_y[curr_weather_data_index] );
        println(" \t the calculated offset'ed coord (which just went offscreen) is "+curr_lineEnd_x+", "+curr_lineEnd_y );
        println(" \t the new offset x/y is "+coords_offset_x+", "+coords_offset_y );
      }
    }

    // ------ 

    // start at one, so previous points can be drawn...
    // (well, there are various ways of doing this, but this is one working one...)
    for( int i = wind_vectors_start_index; i <= curr_weather_data_index; i++ ){

      // quick feedback
      if( debug_b > 4 ){
        println("\t drawing all points, working on point num "+curr_weather_data_index );
      }

      // set the colour temperature if we're colouring things according to temperature
      // ... if appropriate
      if( doing_temperature_colouring_of_nonzoomed_in_wind_vector_line || doing_temperature_colouring_of_nonzoomed_in_cross_strokes ){
        curr_temp_colour = fetch_colour_according_to_temp( temperatures[i] );
      }

      // draw the weather vector start/end points
      if( drawing_all_pts_nonmagnified_weather_vector_pts ){
        // draw the line
        if( drawing_all_pts_nonmagnified_weather_vector_pts ){
          // set stroke
          noFill();
          // if we're colouring according to the the temperature
          if( doing_temperature_colouring_of_nonzoomed_in_wind_vector_line ){
            stroke( curr_temp_colour, temperature_coloured_non_zoomed_in_wind_vector_line );
          }
          // or just do the usual
          else {
            stroke( nonzoomed_line_general_weather_coords_stroke_colour );
          }
          // set stroke weight
          strokeWeight( nonzoomed_line_general_weather_coords_stroke_weight );

          // draw the line
          // NOTE: the 'i-1' indicies!
          // line( new_lineStart_x, new_lineStart_y, new_lineEnd_x, new_lineEnd_y );
          line( wind_location_coords_x[i-1]+coords_offset_x, wind_location_coords_y[i-1]+coords_offset_y, wind_location_coords_x[i]+coords_offset_x, wind_location_coords_y[i]+coords_offset_y );
        }
      }



      // then the cross lines
      if( drawing_all_pts_nonmagnified_cross_lines ){
        //// then the cross lines form the inbetween positions


          // if we're colouring according to the temperature
        if( doing_temperature_colouring_of_nonzoomed_in_cross_strokes ){
          stroke( curr_temp_colour, temperature_coloured_non_zoomed_in_cross_strokes );
        }
        // or just do the usual
        else{
          // set stroke colour  for the corss lines...
          stroke( nonzoomed_line_cross_line_stroke_colour );
        }
        // set stroke weight...
        strokeWeight( nonzoomed_line_cross_line_stroke_weight );

        // find the offset in between point coords
        //// float in_btw_pt_offset_coords_x = wind_location_inbtw_pts_coords_x[curr_weather_data_index] + coords_offset_x ;
        //// float in_btw_pt_offset_coords_y = wind_location_inbtw_pts_coords_y[curr_weather_data_index] + coords_offset_y ;
        float in_btw_pt_offset_coords_x = wind_location_inbtw_pts_coords_x[ i ] + coords_offset_x ;
        float in_btw_pt_offset_coords_y = wind_location_inbtw_pts_coords_y[ i ] + coords_offset_y ;


        // find the line endpoints' coords
        // to the first end
        float cross_line_part_one_end_coords_x = (wind_location_inbtw_pts_coords_x[ i ] + wind_location_inbtw_pt_cross_line_part_one_vector_x[ i ]) + coords_offset_x ;
        float cross_line_part_one_end_coords_y = (wind_location_inbtw_pts_coords_y[ i ] + wind_location_inbtw_pt_cross_line_part_one_vector_y[ i ]) + coords_offset_y ;
        // to the other end
        float cross_line_part_two_end_coords_x = (wind_location_inbtw_pts_coords_x[ i ] + wind_location_inbtw_pt_cross_line_part_two_vector_x[ i ]) + coords_offset_x ;
        float cross_line_part_two_end_coords_y = (wind_location_inbtw_pts_coords_y[ i ] + wind_location_inbtw_pt_cross_line_part_two_vector_y[ i ]) + coords_offset_y ;


        // then draw the two lines
        // part one
        line( in_btw_pt_offset_coords_x, in_btw_pt_offset_coords_y, cross_line_part_one_end_coords_x, cross_line_part_one_end_coords_y );
        // part two
        line( in_btw_pt_offset_coords_x, in_btw_pt_offset_coords_y, cross_line_part_two_end_coords_x, cross_line_part_two_end_coords_y );

        /*
         // feedback
         if( debug_b > 4 ){
         println(" drawing the line here... \n\t the wind_location_coords_x/y coords are "+wind_location_coords_x[i]+","+wind_location_coords_y[i]);
         println("\t and the wind_location_inbtw_pt_cross_line_part_one_vector_x/y = "+wind_location_inbtw_pt_cross_line_part_one_vector_x[i]+", "+wind_location_inbtw_pt_cross_line_part_one_vector_y[i]);
         println("\t the 
         }
         */

      }
    }

  }













  // ----------------------------------

  // this is a modified version of the function below,
  // drawing the small line.. [offscreen]

  void draw_all_points_up_to_current_weather_data_index_offscreen(){

    //    /*
    // officially start the drawing 
    offscreen_drawing_area.beginDraw();



    // ------ draw from the previous coord value to the current one



    // -- find the 'in-screen' offset coordinates
    // using the offset values to generate an onscreen
    // value for the 'raw' windcoords
    float new_lineStart_x = wind_location_coords_x[curr_weather_data_index-1] + coords_offset_x ;
    float new_lineStart_y = wind_location_coords_y[curr_weather_data_index-1] + coords_offset_y ;
    // -- 
    float new_lineEnd_x = wind_location_coords_x[curr_weather_data_index] + coords_offset_x ;
    float new_lineEnd_y = wind_location_coords_y[curr_weather_data_index] + coords_offset_y ;




    // start at one, so previous points can be drawn...
    // (well, there are various ways of doing this, but this is one working one...)
    // for( int i = 1; i <= curr_weather_data_index; i++ ){

    // quick feedback
    if( debug_b > 4 ){
      println("\t drawing all points, working on point num "+curr_weather_data_index );
    }


    // draw the weather vector start/end points
    if( drawing_all_pts_nonmagnified_weather_vector_pts ){
      // draw the line
      if( drawing_all_pts_nonmagnified_weather_vector_pts ){
        // set stroke
        offscreen_drawing_area.noFill();
        offscreen_drawing_area.stroke( nonzoomed_line_general_weather_coords_stroke_colour );
        // set stroke weight
        offscreen_drawing_area.strokeWeight( nonzoomed_line_general_weather_coords_stroke_weight );

        // draw the line
        // NOTE: the 'i-1' indicies!
        offscreen_drawing_area.line( new_lineStart_x, new_lineStart_y, new_lineEnd_x, new_lineEnd_y );
        //line( wind_location_coords_x[i-1], wind_location_coords_y[i-1],wind_location_coords_x[i], wind_location_coords_y[i]);
      }
    }



    // then the cross lines
    if( drawing_all_pts_nonmagnified_cross_lines ){
      //// then the cross lines form the inbetween positions

        // set stroke colour  for the corss lines...
      offscreen_drawing_area.stroke( nonzoomed_line_cross_line_stroke_colour );
      // set stroke weight...
      offscreen_drawing_area.strokeWeight( nonzoomed_line_cross_line_stroke_weight );

      // find the offset in between point coords
      float in_btw_pt_offset_coords_x = wind_location_inbtw_pts_coords_x[curr_weather_data_index] + coords_offset_x ;
      float in_btw_pt_offset_coords_y = wind_location_inbtw_pts_coords_y[curr_weather_data_index] + coords_offset_y ;


      // find the line endpoints' coords
      // to the first end
      float cross_line_part_one_end_coords_x = wind_location_inbtw_pts_coords_x[curr_weather_data_index] + wind_location_inbtw_pt_cross_line_part_one_vector_x[curr_weather_data_index] + coords_offset_x ;
      float cross_line_part_one_end_coords_y = wind_location_inbtw_pts_coords_y[curr_weather_data_index] + wind_location_inbtw_pt_cross_line_part_one_vector_y[curr_weather_data_index] + coords_offset_y ;
      // to the other end
      float cross_line_part_two_end_coords_x = wind_location_inbtw_pts_coords_x[curr_weather_data_index] + wind_location_inbtw_pt_cross_line_part_two_vector_x[curr_weather_data_index] + coords_offset_x ;
      float cross_line_part_two_end_coords_y = wind_location_inbtw_pts_coords_y[curr_weather_data_index] + wind_location_inbtw_pt_cross_line_part_two_vector_y[curr_weather_data_index] + coords_offset_y ;

      // then draw the two lines
      // part one
      offscreen_drawing_area.line( in_btw_pt_offset_coords_x, in_btw_pt_offset_coords_y, cross_line_part_one_end_coords_x, cross_line_part_one_end_coords_y );
      // part two
      offscreen_drawing_area.line( in_btw_pt_offset_coords_x, in_btw_pt_offset_coords_y, cross_line_part_two_end_coords_x, cross_line_part_two_end_coords_y );

      /*
         // feedback
       if( debug_b > 4 ){
       println(" drawing the line here... \n\t the wind_location_coords_x/y coords are "+wind_location_coords_x[i]+","+wind_location_coords_y[i]);
       println("\t and the wind_location_inbtw_pt_cross_line_part_one_vector_x/y = "+wind_location_inbtw_pt_cross_line_part_one_vector_x[i]+", "+wind_location_inbtw_pt_cross_line_part_one_vector_y[i]);
       println("\t the 
       }
       */

    }


    // ---- then check if the coords are inside, 
    // and if they're not, then we fix things for the next loop
    if( ( new_lineStart_x > stage_width || new_lineStart_x < 0 ) || 
      ( new_lineStart_y > stage_height || new_lineStart_y < 0 ) ){

      // blank out the offscreen draw area
      offscreen_drawing_area.fill( background_colour );
      offscreen_drawing_area.rect( 0, 0, stage_width, stage_height );

      // find out the new screen offsets
      coords_offset_x = start_point_x - wind_location_coords_x[curr_weather_data_index];
      coords_offset_y = start_point_y - wind_location_coords_y[curr_weather_data_index];      

    }
    // officially end the drawing
    offscreen_drawing_area.endDraw();

    // then, after all is done, draw things to screen
    image( offscreen_drawing_area, 0, 0 );
    // trying 'set' instead
    ////set( 0, 0, offscreen_drawing_area );
    //}
  }







  // ------------------------------------



  // this function draws the points one by one

  void draw_all_points_up_to_current_weather_data_index(){

    // start at one, so previous points can be drawn...
    // (well, there are various ways of doing this, but this is one working one...)
    for( int i = 1; i <= curr_weather_data_index; i++ ){

      // quick feedback
      if( debug_b > 4 ){
        println("\t drawing all points, working on point num "+i );
      }


      // draw the weather vector start/end points
      if( drawing_all_pts_nonmagnified_weather_vector_pts ){
        // draw the line
        if( drawing_all_pts_nonmagnified_weather_vector_pts ){
          // set stroke
          stroke( nonzoomed_line_general_weather_coords_stroke_colour );
          // set stroke weight
          strokeWeight( nonzoomed_line_general_weather_coords_stroke_weight );

          // draw the line
          // NOTE: the 'i-1' indicies!
          line( wind_location_coords_x[i-1], wind_location_coords_y[i-1],wind_location_coords_x[i], wind_location_coords_y[i]);
        }
      }


      // then the cross lines
      if( drawing_all_pts_nonmagnified_cross_lines){
        //// then the cross lines form the inbetween positions

          // stroke colour 
        stroke( nonzoomed_line_cross_line_stroke_colour );
        // stroke weight...
        strokeWeight( nonzoomed_line_cross_line_stroke_weight );

        /* - this doesn't quite work....
         // find the line endpoints' coords
         // to the first end
         float cross_line_part_one_end_coords_x = wind_location_inbtw_pt_cross_line_part_one_vector_x[i] + wind_location_inbtw_pt_cross_line_part_one_vector_x[i];
         float cross_line_part_one_end_coords_y = wind_location_inbtw_pt_cross_line_part_one_vector_y[i] + wind_location_inbtw_pt_cross_line_part_one_vector_y[i];
         // to the other end
         float cross_line_part_two_end_coords_x = wind_location_inbtw_pt_cross_line_part_one_vector_x[i] + wind_location_inbtw_pt_cross_line_part_two_vector_x[i];
         float cross_line_part_two_end_coords_y = wind_location_inbtw_pt_cross_line_part_one_vector_y[i] + wind_location_inbtw_pt_cross_line_part_two_vector_y[i];
         
         // then draw the two lines
         // part one
         line( wind_location_inbtw_pt_cross_line_part_one_vector_x[i], wind_location_inbtw_pt_cross_line_part_one_vector_y[i], cross_line_part_one_end_coords_x, cross_line_part_one_end_coords_y );
         // part two
         line( wind_location_inbtw_pt_cross_line_part_one_vector_x[i], wind_location_inbtw_pt_cross_line_part_one_vector_y[i], cross_line_part_two_end_coords_x, cross_line_part_two_end_coords_y );
         */
        // find the line endpoints' coords
        // to the first end
        float cross_line_part_one_end_coords_x = wind_location_inbtw_pts_coords_x[i] + wind_location_inbtw_pt_cross_line_part_one_vector_x[i];
        float cross_line_part_one_end_coords_y = wind_location_inbtw_pts_coords_y[i] + wind_location_inbtw_pt_cross_line_part_one_vector_y[i];
        // to the other end
        float cross_line_part_two_end_coords_x = wind_location_inbtw_pts_coords_x[i] + wind_location_inbtw_pt_cross_line_part_two_vector_x[i];
        float cross_line_part_two_end_coords_y = wind_location_inbtw_pts_coords_y[i] + wind_location_inbtw_pt_cross_line_part_two_vector_y[i];

        // then draw the two lines
        // part one
        line( wind_location_inbtw_pts_coords_x[i], wind_location_inbtw_pts_coords_y[i], cross_line_part_one_end_coords_x, cross_line_part_one_end_coords_y );
        // part two
        line( wind_location_inbtw_pts_coords_x[i], wind_location_inbtw_pts_coords_y[i], cross_line_part_two_end_coords_x, cross_line_part_two_end_coords_y );

        /*
// feedback
         if( debug_b > 4 ){
         println(" drawing the line here... \n\t the wind_location_coords_x/y coords are "+wind_location_coords_x[i]+","+wind_location_coords_y[i]);
         println("\t and the wind_location_inbtw_pt_cross_line_part_one_vector_x/y = "+wind_location_inbtw_pt_cross_line_part_one_vector_x[i]+", "+wind_location_inbtw_pt_cross_line_part_one_vector_y[i]);
         println("\t the 
         }
         */

      }

    }
  } 


  /*  
   // -- - -
   
   // this function draws all the points in one go
   
   void draw_all_at_once(){
   // something...
   
   }
   
   
   // -- - -
   
   // this function draws the points one by one
   
   void draw_one_at_a_time(){
   
   } 
   */

}















