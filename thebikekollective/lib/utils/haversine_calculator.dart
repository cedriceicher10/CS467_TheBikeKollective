import 'dart:math';

// References:
//   https://www.movable-type.co.uk/scripts/latlong.html
//   https://en.wikipedia.org/wiki/Haversine_formula

double haversineCalculator(
    double userLat, double userLon, double bikeLat, double bikeLon) {
  // All angles MUST BE IN RADIANS
  const EARTH_RADIUS = 6371e3; // m

  double phi1 = userLat * pi / 180;
  double phi2 = bikeLat * pi / 180;
  double deltaPhi = (bikeLat - userLat) * pi / 180;
  double deltaLambda = (bikeLon - userLon) * pi / 180;

  double a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
      cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  double greatCircleDistanceMeters = EARTH_RADIUS * c; // m
  double greatCircleDistanceMiles = greatCircleDistanceMeters / 1609; // mi

  return greatCircleDistanceMiles;
}
