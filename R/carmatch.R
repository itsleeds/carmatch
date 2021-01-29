# single place for functions (for now)
cm_get = function(u = "https://www.eea.europa.eu/data-and-maps/data/co2-cars-emission-18/co2-emissions-cars-2017-provisional/co2_passengers_cars_v15_csv/at_download/file", dir = tempdir()) {
  f = file.path(dir, "co2.zip")
  dd = file.path(dir, "co2")
if(!file.exists(f)) {
    download.file(u, f)
    dir.create(dd)
    unzip(f, exdir = dd)
  }
  f = list.files(dd, full.names = TRUE)
  print(f)
  # every single car type

  read.csv(
    f, fileEncoding = "UTF-16", sep = "\t", header = FALSE
  )
  # fails:
  # readr::read_tsv(f, locale = readr::locale(encoding="UTF-16"))


}
d_raw = cm_get()
system.time(saveRDS(d_raw, "d_raw_euco2.Rds"))
# 35s on fast computer! 40 MB
