import 'package:lifelinkai/models/donation.dart';
import 'package:lifelinkai/models/donor.dart';

class DonorUtils {
  static const int bloodPerDonor = 250;

  static List<Donor> convertDonationToDonorList(List<Donation> donations) {
    return donations.map((donation) {
      return Donor(
        id: donation.id,
        fullname: donation.fullname,
        cin: donation.cin,
        bloodType: donation.bloodType,
        email: donation.email,
        lastDonationDate: donation.lastDonationDate,
        firstDonationDate: donation.firstDonationDate,
        frequency: donation.frequence,
        prediction: "Not defined",
        predictionColor: null,
      );
    }).toList();
  }

  static List<Donor> getFilteredDonors(
    List<Donor> donorList,
    String searchQuery,
    String selectedFilter,
  ) {
    List<Donor> filtered = donorList;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((donor) =>
          donor.cin.isNotEmpty &&
          donor.cin.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }

    // Apply prediction filter
    switch (selectedFilter) {
      case 'predicted':
        filtered = filtered.where((donor) => 
            donor.prediction != "Not defined").toList();
        break;
      case 'not_predicted':
        filtered = filtered.where((donor) => 
            donor.prediction == "Not defined").toList();
        break;
      case 'will_donate':
        filtered = filtered.where((donor) => 
            donor.predictionValue == 1).toList();
        break;
      case 'wont_donate':
        filtered = filtered.where((donor) => 
            donor.predictionValue == 0).toList();
        break;
      case 'all':
      default:
        // No additional filtering
        break;
    }

    return filtered;
  }

  static Map<String, dynamic> calculateBloodStats(List<Donor> donors) {
    final Map<String, dynamic> stats = {
      'total': 0,
      'byType': {},
      'potentialDonors': 0,
    };

    for (final donor in donors) {
      final willDonate = donor.predictionValue == 1;

      if (willDonate) {
        stats['potentialDonors'] = (stats['potentialDonors'] as int) + 1;
        stats['total'] = (stats['total'] as int) + bloodPerDonor;

        if (!(stats['byType'] as Map).containsKey(donor.bloodType)) {
          (stats['byType'] as Map)[donor.bloodType] = {'count': 0, 'volume': 0};
        }

        (stats['byType'] as Map)[donor.bloodType]['count'] += 1;
        (stats['byType'] as Map)[donor.bloodType]['volume'] += bloodPerDonor;
      }
    }

    return stats;
  }

  static Map<String, dynamic> computeFeatures(Donor donor) {
    final now = DateTime.now();
    final lastDonationDate = DateTime.parse(donor.lastDonationDate);
    final firstDonationDate = donor.firstDonationDate.isNotEmpty
        ? DateTime.parse(donor.firstDonationDate)
        : now;

    final recency = ((now.difference(lastDonationDate).inDays) / 30.44).floor();
    final time = ((now.difference(firstDonationDate).inDays) / 30.44).floor();

    return {'recency': recency, 'frequency': donor.frequency, 'time': time};
  }
}