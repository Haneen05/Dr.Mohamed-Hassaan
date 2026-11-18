String toArabicNumber(int value) {
  const englishNumbers = '0123456789';
  const arabicNumbers = '٠١٢٣٤٥٦٧٨٩';

  return value.toString().split('').map((digit) {
    final index = englishNumbers.indexOf(digit);

    if (index == -1) {
      return digit;
    }

    return arabicNumbers[index];
  }).join();
}

String localizedNumber({required int value, required bool isArabic}) {
  return isArabic ? toArabicNumber(value) : value.toString();
}
