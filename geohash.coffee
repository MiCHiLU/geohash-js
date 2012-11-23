# geohash.js
# Geohash library for Javascript
# (c) 2008 David Troy
# Distributed under the MIT License

( (window) ->

  north    = 0
  east  = 1
  south = 2
  west   = 3
  even   = 0
  odd    = 1

  BITS = [16, 8, 4, 2, 1]

  BASE32 = "0123456789bcdefghjkmnpqrstuvwxyz"

  NEIGHBORS =
    0: {}
    1: {}
    2: {}
    3: {}

  BORDERS =
    0: {}
    1: {}
    2: {}
    3: {}

  NEIGHBORS[south][odd] = NEIGHBORS[west][even]   = "238967debc01fg45kmstqrwxuvhjyznp"
  NEIGHBORS[north][odd] = NEIGHBORS[east][even]   = "bc01fg45238967deuvhjyznpkmstqrwx"
  NEIGHBORS[west][odd]  = NEIGHBORS[south][even]  = "14365h7k9dcfesgujnmqp0r2twvyx8zb"
  NEIGHBORS[east][odd]  = NEIGHBORS[north][even]  = "p0r21436x8zb9dcf5h7kjnmqesgutwvy"

  BORDERS[south][odd]   = BORDERS[west][even]     = "0145hjnp"
  BORDERS[north][odd]   = BORDERS[east][even]     = "bcfguvyz"
  BORDERS[west][odd]    = BORDERS[south][even]    = "028b"
  BORDERS[east][odd]    = BORDERS[north][even]    = "prxz"

  refine_interval = (interval, cd, mask) ->
    if cd & mask
      interval[0] = (interval[0] + interval[1]) / 2
    else
      interval[1] = (interval[0] + interval[1]) / 2
    return

  calculateAdjacent = (srcHash, dir) ->
    srcHash = srcHash.toLowerCase()
    lastChr = srcHash.charAt(srcHash.length - 1)
    type = (if (srcHash.length % 2) then odd else even)
    base = srcHash.substring(0, srcHash.length - 1)
    base = calculateAdjacent(base, dir) unless BORDERS[dir][type].indexOf(lastChr) is -1
    base + BASE32[NEIGHBORS[dir][type].indexOf(lastChr)]

  calculateAdjacents = (srcHash) ->
    result =
      "c" : srcHash
      "n" : calculateAdjacent(srcHash, "n")
      "e" : calculateAdjacent(srcHash, "e")
      "s" : calculateAdjacent(srcHash, "s")
      "w" : calculateAdjacent(srcHash, "w")
    result["ne"] = calculateAdjacent(result["n"], "e")
    result["se"] = calculateAdjacent(result["s"], "e")
    result["sw"] = calculateAdjacent(result["s"], "w")
    result["nw"] = calculateAdjacent(result["n"], "w")
    result

  decodeGeoHash = (geohash) ->
    is_even = 1
    lat = [-90.0, 90.0]
    lon = [-180.0, 180.0]
    lat_err = 90.0
    lon_err = 180.0
    i = 0
    while i < geohash.length
      c = geohash[i]
      cd = BASE32.indexOf(c)
      j = 0
      while j < 5
        mask = BITS[j]
        if is_even
          lon_err /= 2
          refine_interval lon, cd, mask
        else
          lat_err /= 2
          refine_interval lat, cd, mask
        is_even = not is_even
        j++
      i++
    [(lat[0] + lat[1]) / 2, (lon[0] + lon[1]) / 2]

  encodeGeoHash = (latitude, longitude) ->
    is_even = 1
    i = 0
    lat = [-90.0, 90.0]
    lon = [-180.0, 180.0]
    bit = 0
    ch = 0
    precision = 12
    geohash = ""
    while geohash.length < precision
      if is_even
        mid = (lon[0] + lon[1]) / 2
        if longitude > mid
          ch |= BITS[bit]
          lon[0] = mid
        else
          lon[1] = mid
      else
        mid = (lat[0] + lat[1]) / 2
        if latitude > mid
          ch |= BITS[bit]
          lat[0] = mid
        else
          lat[1] = mid
      is_even = not is_even
      if bit < 4
        bit++
      else
        geohash += BASE32[ch]
        bit = 0
        ch = 0
    geohash

  geohash = window.geohash or (window.geohash =
    decode: decodeGeoHash
    encode: encodeGeoHash
    adjacent: calculateAdjacent
    adjacents: calculateAdjacents
  )

  return
)(window)
