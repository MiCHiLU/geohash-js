# geohash.js
# Geohash library for Javascript
# (c) 2008 David Troy
# Distributed under the MIT License

BITS = [16, 8, 4, 2, 1]

BASE32 = "0123456789bcdefghjkmnpqrstuvwxyz"
NEIGHBORS =
  right:
    even: "bc01fg45238967deuvhjyznpkmstqrwx"
  left:
    even: "238967debc01fg45kmstqrwxuvhjyznp"
  top:
    even: "p0r21436x8zb9dcf5h7kjnmqesgutwvy"
  bottom:
    even: "14365h7k9dcfesgujnmqp0r2twvyx8zb"
BORDERS =
  right:
    even: "bcfguvyz"
  left:
    even: "0145hjnp"
  top:
    even: "prxz"
  bottom:
    even: "028b"

NEIGHBORS.bottom.odd = NEIGHBORS.left.even
NEIGHBORS.top.odd = NEIGHBORS.right.even
NEIGHBORS.left.odd = NEIGHBORS.bottom.even
NEIGHBORS.right.odd = NEIGHBORS.top.even

BORDERS.bottom.odd = BORDERS.left.even
BORDERS.top.odd = BORDERS.right.even
BORDERS.left.odd = BORDERS.bottom.even
BORDERS.right.odd = BORDERS.top.even

refine_interval = (interval, cd, mask) ->
  if cd and mask
    interval[0] = (interval[0] + interval[1]) / 2
  else
    interval[1] = (interval[0] + interval[1]) / 2
  return

calculateAdjacent = (srcHash, dir) ->
  srcHash = srcHash.toLowerCase()
  lastChr = srcHash.charAt(srcHash.length - 1)
  type = (if (srcHash.length % 2) then "odd" else "even")
  base = srcHash.substring(0, srcHash.length - 1)
  base = calculateAdjacent(base, dir) unless BORDERS[dir][type].indexOf(lastChr) is -1
  base + BASE32[NEIGHBORS[dir][type].indexOf(lastChr)]

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
  lat[2] = (lat[0] + lat[1]) / 2
  lon[2] = (lon[0] + lon[1]) / 2
  latitude: lat
  longitude: lon

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
    unless bit < 4
      geohash += BASE32[ch]
      bit = 0
      ch = 0
  geohash
