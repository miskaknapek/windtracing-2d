
/*

 090616
 
 this function goes through the time data
 and finds where the various time changes are,
 and saves these (as numbers indicating the 'level' of time changes)
 in an time_changes_array
 
 the different time changes we're recording
 ->   |  year ( 0 )  |  month ( 1 )  |  day ( 2 )  |  hour ( 3 )  |  minute ( 4 )  |  second ( 5 )  |
 
 */




void fetch_date_n_time_changes() {


  // remember the previous date n time...
  // YES YES, a bit of hardcoding....
  String[] prev_timestamp_as_array_wo_letters = fetch_timestamp_array_without_letters( 0 );


  // loop and compare the strings 
  for( int i = 0; i < timestamps_array.length ; i++ ){
    // debugging version:
    /* for( int i = 0; i < 10 ; i++ ){ */

    // fetch the current timestamp as a String[] of numbers... no letter
    String[] curr_timestamp_as_array_wo_letters = fetch_timestamp_array_without_letters( i );



    // then fetch the date portion of the string
    //// String[]
    // some feedback
    if( debug_fetch_time_date_changes > 3 ){
      /*
      println(" the complete_timestamp_as_two_bits looks like this: \n part 1");
       println( complete_timestamp_as_two_bits[0] );
       println("  /  part 2 ");
       println( complete_timestamp_as_two_bits[1] ); */
      println(" the curr_timestamp_as_array_wo_letters looks like this");
      println( curr_timestamp_as_array_wo_letters );
    }



    // --- then do the comparisons
    //      to see if there are any changes

      ////  year check
    if( !(curr_timestamp_as_array_wo_letters[year_pos].equals( prev_timestamp_as_array_wo_letters[year_pos])) ){

      // a bit of feebble debugging
      if( debug_fetch_time_date_changes > 3 ){
        println(" ooh! loops like we have a year change ! "); 
      }
      // set the indication as appropriate
      dateNtime_changes_array[i] = year_change;
    }
    ////  month check
    else if( !(curr_timestamp_as_array_wo_letters[ month_pos ].equals( prev_timestamp_as_array_wo_letters[ month_pos ])) ){

      // a bit of feebble debugging
      if( debug_fetch_time_date_changes > 3 ){
        println(" ooh! loops like we have a month change ! "); 
      }
      // set the indication as appropriate
      dateNtime_changes_array[i] = month_change;
    }
    ////  day check
    else if( !(curr_timestamp_as_array_wo_letters[ day_pos ].equals( prev_timestamp_as_array_wo_letters[ day_pos ])) ){

      // a bit of feebble debugging
      if( debug_fetch_time_date_changes > 3 ){
        println(" ooh! loops like we have a day change ! "); 
      }
      // set the indication as appropriate
      dateNtime_changes_array[i] = day_change;
    }
    ////  hour check
    else if( !(curr_timestamp_as_array_wo_letters[ hour_pos ].equals( prev_timestamp_as_array_wo_letters[ hour_pos ])) ){

      // a bit of feebble debugging
      if( debug_fetch_time_date_changes > 3 ){
        println(" ooh! loops like we have a hour change ! "); 
      }
      // set the indication as appropriate
      dateNtime_changes_array[i] = hour_change;
    }    
    ////  minute check 
    else if( !(curr_timestamp_as_array_wo_letters[ min_pos ].equals( prev_timestamp_as_array_wo_letters[ min_pos ])) ){

      // a bit of feebble debugging
      if( debug_fetch_time_date_changes > 3 ){
        println(" ooh! loops like we have a minute change ! "); 
      }
      // set the indication as appropriate
      dateNtime_changes_array[i] = min_change;
    }    


    // continue


      // ------- end of loop things

    //   remember to save the current date and time as the previous
    prev_timestamp_as_array_wo_letters = curr_timestamp_as_array_wo_letters;
  }

  // a bit of feebble debugging -- let's print the dateNtime_changes_array 
  if( debug_fetch_time_date_changes > 3 ){
    println(" \n ok! - done checking dates... now printing the dateNtime_changes_array "); 
    println( dateNtime_changes_array );
  }

}




// -----------------------------------------------------------------------


/*

 help function to the above function,
 to take a timestamp string from the timestamps_array,
 and return it as a String[], without the letter portions of things
 
 */

String[] fetch_timestamp_array_without_letters( int timestamp_array_index ){

  // start by fetching the complete timestamp, separating the date and the time
  // (there's that [T] in the middle... 
  String[] complete_timestamp_as_two_bits = splitTokens( timestamps_array[ timestamp_array_index ], "T");

  // separate out the two parts and put them together
  String[] date_part_of_time_stamp_separated = splitTokens( complete_timestamp_as_two_bits[0], "-" );
  String[] time_part_of_time_stamp_separated = splitTokens( complete_timestamp_as_two_bits[1], ":" );    

  // then put the bits together
  String[] curr_time_stamp_as_cleaned_timestamp = concat( date_part_of_time_stamp_separated, time_part_of_time_stamp_separated );

  // and then finally return something
  return curr_time_stamp_as_cleaned_timestamp ;
}



// ------------------------------------------------------------------------


void print_dateNtime_changes_releavant_arrays() {

  println( "\n hi! \n\t let us try printing the arrays generated \n\t via the fet date N time functions \n\t - including the coordinate/vector such. ");
  println(" dateNtime_changes_array" );
  println( dateNtime_changes_array );

  ////    date_n_time_line_part 1
  println( "____dateNtime_visual_markup_cross_line_lengthOfOne_part_one_x :" );
  println( dateNtime_visual_markup_cross_line_lengthOfOne_part_one_x );
  println( " dateNtime_visual_markup_cross_line_lengthOfOne_part_one_y : ") ;
  println( dateNtime_visual_markup_cross_line_lengthOfOne_part_one_y ) ;
  ////    date n time line part 2
  println(" ____dateNtime_visual_markup_cross_line_lengthOfOne_part_two_x : ");
  println( dateNtime_visual_markup_cross_line_lengthOfOne_part_two_x );
  println(" dateNtime_visual_markup_cross_line_lengthOfOne_part_two_y : ");
  println(   dateNtime_visual_markup_cross_line_lengthOfOne_part_two_y );

  println(" .... and just to be safe, we're printing the wind_location_coords_x... : ");
  println( wind_location_coords_x );

  println(" \n\t and that's all the dateNtime changes relevant printing... ! \n\n ");

}









// ------------------------------------------------------------------------


