import 'package:lifelinkai/models/donor.dart';
import 'package:lifelinkai/services/api_service.dart';
import 'package:lifelinkai/utils/donor_utils.dart';

class DonorPredictionService {
  Future<List<Donor>> predictDonors(List<Donor> donorList) async {
    final samples = donorList.map(DonorUtils.computeFeatures).toList();
    
    final predictions = await ApiService.predictDonors(samples);

    final updated = List<Donor>.from(donorList);
    for (int i = 0; i < updated.length; i++) {
      updated[i] = updated[i].copyWith(
        prediction: predictions[i] == 1 ? "Will Donate" : "Will Not Donate",
        predictionValue: predictions[i],
        predictionColor: predictions[i] == 1 ? "green" : "red",
      );
    }

    return updated;
  }
}