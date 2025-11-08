String map_type(String input) {
  if (input == "<class 'float'>" ||
      input == "<class 'numpy.float64'>" ||
      input == "<class 'numpy.float32'>" ||
      input == "f4" ||
      input == "f8") {
    return "float";
  }
  return "undefined";
}
