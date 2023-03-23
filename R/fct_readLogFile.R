#' @title Read single thermo orbitrap log file
#' @description Read single thermo orbitrap log file as a data frame.
#' @param log single log file
#' @importFrom utils read.table
#' @importFrom dplyr vars across
#' @return a data frame
#' @noRd

Date <- NULL
read_log <- function(log) {
  ## define col names. In some cases, the log file starts without colnames or with colnames in the middle
  logColnames <- c(
    "Time [sec]",
    "Date",
    "Up-Time [days]",
    "Vacuum 1 (HV) [mbar]",
    "Vacuum 2 (UHV) [mbar]",
    "Vacuum 3 (Fore) [mbar]",
    "Vacuum 4/humidity [mbar]",
    "TURBO1_TEMP_BEARING_R [\u00B0C]",
    "TURBO1_TEMP_MOTOR_R [\u00B0C]",
    "TURBO1_TEMP_BOTTOMPART_R [\u00B0C]",
    "TURBO1_TEMP_POWERSTAGE_R [\u00B0C]",
    "TURBO1_TEMP_ELECTRONICS_R [\u00B0C]",
    "TURBO1_VOLT_R [V]",
    "TURBO1_CURR_R [A]",
    "TURBO2_TEMP_BEARING_R [\u00B0C]",
    "TURBO2_TEMP_MOTOR_R [\u00B0C]",
    "TURBO2_TEMP_BOTTOMPART_R [\u00B0C]",
    "TURBO2_TEMP_POWERSTAGE_R [\u00B0C]",
    "TURBO2_TEMP_ELECTRONICS_R [\u00B0C]",
    "TURBO2_VOLT_R [V]",
    "TURBO2_CURR_R [A]",
    "TURBO3_TEMP_BEARING_R [\u00B0C]",
    "TURBO3_TEMP_MOTOR_R [\u00B0C]",
    "TURBO3_TEMP_BOTTOMPART_R [\u00B0C]",
    "TURBO3_TEMP_POWERSTAGE_R [\u00B0C]",
    "TURBO3_TEMP_ELECTRONICS_R [\u00B0C]",
    "TURBO3_VOLT_R [V]",
    "TURBO3_CURR_R [A]",
    "Ambient Temperature (raw) [\u00B0C]",
    "Ambient Humidity result [%]",
    "Capillary Temperature [\u00B0C]",
    "IOS Heatsink Temperature [\u00B0C]",
    "IOS RF0-1 Freq [kHz]",
    "IOS RF2-3 Freq [kHz]",
    "Ctrap RF amp [Vpp]",
    "Ctrap AMP current [A]",
    "Ctrap Freq [MHz]",
    "CE-pos electronics temperature (   act.   ) [\u00B0C]",
    "CE-neg electronics temperature (   act.   ) [\u00B0C]",
    "Analyzer temperature sensor [\u00B0C]",
    "Analyzer temp sensor (filtered) [\u00B0C]",
    "Analyzer temperature (with delay model) [\u00B0C]",
    "CEPS Peltier temperature sensor [\u00B0C]",
    "Quad Detector Temperature [\u00B0C]"
  )
  ## sometimes the log file contains additional empty column, so I only keep the first 44 columns.
  df <- read.table(log, header = TRUE, check.names = FALSE, skipNul = TRUE, sep = "\t", fileEncoding = "latin1")[1:44]

  ## identify rows with character values. Because 2nd column is date, a character column, I used all here.
  char_rows <- apply(df, 1, function(x) all(grepl("[[:alpha:]]", x)))
  df <- df[!char_rows, ]
  colnames(df) <- logColnames

  ## convert other columns to numeric.
  df <- df %>%
    dplyr::mutate(across(-Date, as.numeric))
  return(df)
}

#' @title Read a batch of Thermo Orbitrap log files
#' @description Read a batch of Thermo Orbitrap log files as a data frame.
#' @param logFile a batch of log files
#' @importFrom purrr map_df
#' @importFrom dplyr %>%
#' @importFrom stats na.omit
#' @return a data frame
#' @noRd

readLogFile <- function(logFile){
  purrr::map_df(logFile, read_log) %>%
    na.omit() %>%
    dplyr::mutate(Date = as.POSIXct(Date, format = "%Y-%m-%d %H:%M:%S")) %>%
    dplyr::mutate(Date = format(Date, format="%Y-%m-%d"))
}



