import 'dart:math';

List<double> meanAlongFirstAxis(List<List<double>> matrix) {
  if (matrix.isEmpty) {
    throw ArgumentError("The matrix cannot be empty.");
  }

  // Initialize a list to store the column sums
  List<double> columnSums = List.filled(matrix[0].length, 0.0);

  // Sum up the values in each column
  for (var row in matrix) {
    if (row.length != matrix[0].length) {
      throw ArgumentError("All rows must have the same number of elements.");
    }
    for (int i = 0; i < row.length; i++) {
      columnSums[i] += row[i];
    }
  }

  // Calculate the mean for each column
  int numRows = matrix.length;
  List<double> columnMeans = columnSums.map((sum) => sum / numRows).toList();

  return columnMeans;
}

double cosineSimilarity(List<double> vecA, List<double> vecB) {
  if (vecA.length != vecB.length) {
    throw ArgumentError("Vectors must be of the same length.");
  }

  // Calculate dot product of vecA and vecB
  double dotProduct = 0;
  for (int i = 0; i < vecA.length; i++) {
    dotProduct += vecA[i] * vecB[i];
  }

  // Calculate the magnitudes of vecA and vecB
  double magnitudeA = 0;
  double magnitudeB = 0;
  for (int i = 0; i < vecA.length; i++) {
    magnitudeA += vecA[i] * vecA[i];
    magnitudeB += vecB[i] * vecB[i];
  }

  magnitudeA = sqrt(magnitudeA);
  magnitudeB = sqrt(magnitudeB);

  // Calculate cosine similarity
  return dotProduct / (magnitudeA * magnitudeB);
}

double cosineDistance(List<double> vecA, List<double> vecB) {
  // Cosine distance is 1 minus cosine similarity
  return 1 - cosineSimilarity(vecA, vecB);
}

int findClosestListIndex(
    List<List<double>> referenceSet, List<double> newList) {
  double minDistance = double.infinity;
  int closestIndex = -1;

  for (int i = 0; i < referenceSet.length; i++) {
    double distance = cosineDistance(referenceSet[i], newList);
    print(distance);
    print("Distance to referenceList $i: $distance");

    if (distance < minDistance) {
      minDistance = distance;
      closestIndex = i;
    }
  }

  return closestIndex; // Returns the index of the closest list
}

void main() {
  // Reference set of lists
  List<List<double>> referenceSet = [
    [3.0, 5.0, 7.0],
    [4.0, 6.0, 8.0],
    [5.0, 7.0, 9.0],
  ];
  // referenceSet.add([1.0, 2.0, 3.0]);

  print((referenceSet));

  // New list to compare
  // List<double> newList = [2.0, 3.0, 4.0];

  // Find closest list in the reference set
  // List<double> closestList = findClosestListIndex(referenceSet, newList);

  // print("The closest list to the new list is: $closestList");

    // Calculate the mean along the first axis (i.e., column-wise mean)
  List<double> result = meanAlongFirstAxis(referenceSet);

  print("Mean along the first axis: $result");
}
