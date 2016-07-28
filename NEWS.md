# nycflights13 0.2.0.9000

* `airports` now has a `tzone` column that contains the IANA time zone
  for the airport (#15).

# nycflights13 0.2.0

* `airlines`: `carrier` columns are characters instead of factors (#2).

* `airports`: duplicate entry for BFT removed (#7).

* `flights`:
    
    * new `time_hour` variable combines `year`, `month`, `day`, and 
      `hour` into a single variable (#11).

    * new `sched_dep_time` and `sched_arr_time` variables give scheduled 
      departure and  arrival times - these are more appropriate for connecting 
      to weather data. `hour` and `minute` are now computed from the scheduled 
      departure time, not the actual departure time.

    * missing `tailnum` now recorded as `NA`, not `""` (#10).

* `weather`:
  
  * Includes weather data for all airports.

  * New `time_hour` variable combines `year`, `month`, `day`, `hour` into 
    a single POSIXct variable.

  * Saved as ungrouped.
