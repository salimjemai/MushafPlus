import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_plus/data/countries.dart';
import 'package:mushaf_plus/data/region.dart';

void main() {
  test('typed countries resolve to ISO codes', () {
    expect(countryCodeFor('Tunisia'), 'TN');
    expect(countryCodeFor('tunisie'), 'TN');
    expect(countryCodeFor('TN'), 'TN');
    expect(countryCodeFor('tn'), 'TN');
    expect(countryCodeFor('تونس'), 'TN');
    expect(countryCodeFor('United States'), 'US');
    expect(countryCodeFor('usa'), 'US');
    expect(countryCodeFor('Tunis'), 'TN'); // prefix
    expect(countryCodeFor('Saudi'), 'SA');
    expect(countryCodeFor('Nowhere Land'), isNull);
    expect(countryNameFor('TN'), 'Tunisia');
  });

  test('suggestions start with name matches', () {
    expect(countrySuggestions('tun').first, 'Tunisia');
    expect(countrySuggestions('uni'), contains('United States'));
  });

  test('regional defaults', () {
    expect(Region.flag('TN'), '🇹🇳');
    expect(Region.methodFor('TN'), 'mwl');
    expect(Region.methodFor('US'), 'isna');
    expect(Region.methodFor('EG'), 'egyptian');
    expect(Region.methodFor('PK'), 'karachi');
    expect(Region.hanafiFor('PK'), isTrue);
    expect(Region.hanafiFor('TN'), isFalse);
  });
}
