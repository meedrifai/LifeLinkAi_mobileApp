import 'package:flutter/material.dart';
import '../models/hospital_data.dart';

class HospitalSelector extends StatefulWidget {
  final HospitalData data;
  final Function(List<String>) onFinish;
  final VoidCallback? onCancel;

  const HospitalSelector({
    Key? key,
    required this.data,
    required this.onFinish,
    this.onCancel,
  }) : super(key: key);

  @override
  _HospitalSelectorState createState() => _HospitalSelectorState();
}

class _HospitalSelectorState extends State<HospitalSelector> {
  String selectedRegion = '';
  String selectedDelegation = '';
  String selectedCommune = '';
  List<Delegation> availableDelegations = [];
  List<Commune> availableCommunes = [];
  List<String> hospitals = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.local_hospital, color: Colors.red[600]),
                  const SizedBox(width: 8),
                  const Text(
                    'Hospital Finder',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              if (widget.onCancel != null)
                IconButton(
                  onPressed: widget.onCancel,
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Region Dropdown
          _buildDropdown(
            label: 'Region',
            icon: Icons.location_on,
            value: selectedRegion,
            items: widget.data.regions.map((region) => region.region).toList(),
            onChanged: (value) => _handleRegionChange(value),
            enabled: true,
          ),
          
          const SizedBox(height: 12),
          
          // Delegation Dropdown
          _buildDropdown(
            label: 'Delegation',
            icon: Icons.location_on,
            value: selectedDelegation,
            items: availableDelegations.map((delegation) => delegation.delegation).toList(),
            onChanged: (value) => _handleDelegationChange(value),
            enabled: selectedRegion.isNotEmpty,
          ),
          
          const SizedBox(height: 12),
          
          // Municipality Dropdown
          _buildDropdown(
            label: 'Municipality',
            icon: Icons.business,
            value: selectedCommune,
            items: availableCommunes.map((commune) => commune.commune).toList(),
            onChanged: (value) => _handleCommuneChange(value),
            enabled: selectedDelegation.isNotEmpty,
          ),
          
          if (hospitals.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.local_hospital, color: Colors.red[600], size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Available Hospitals',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                itemCount: hospitals.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.grey[300],
                ),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.local_hospital, size: 16, color: Colors.red[500]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            hospitals[index],
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Buttons
          Row(
            children: [
              if (widget.onCancel != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              if (widget.onCancel != null) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: hospitals.isEmpty ? null : () => widget.onFinish(hospitals),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hospitals.isEmpty ? Colors.grey[300] : const Color(0xFFE53E3E),
                    foregroundColor: hospitals.isEmpty ? Colors.grey[500] : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Confirm Selection',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: enabled ? Colors.white : Colors.grey[100],
          ),
          child: DropdownButtonFormField<String>(
            value: value.isEmpty ? null : value,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              prefixIcon: Icon(icon, size: 16, color: Colors.grey[500]),
            ),
            hint: Text('Choose a ${label.toLowerCase()}'),
            items: enabled
                ? items.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList()
                : [],
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ],
    );
  }

  void _handleRegionChange(String? regionName) {
    if (regionName == null) return;
    
    setState(() {
      selectedRegion = regionName;
      selectedDelegation = '';
      selectedCommune = '';
      availableDelegations = [];
      availableCommunes = [];
      hospitals = [];
      
      final region = widget.data.regions.firstWhere(
        (r) => r.region == regionName,
        orElse: () => Region(region: '', delegations: []),
      );
      
      if (region.region.isNotEmpty) {
        availableDelegations = region.delegations;
      }
    });
  }

  void _handleDelegationChange(String? delegationName) {
    if (delegationName == null) return;
    
    setState(() {
      selectedDelegation = delegationName;
      selectedCommune = '';
      availableCommunes = [];
      hospitals = [];
      
      final delegation = availableDelegations.firstWhere(
        (d) => d.delegation == delegationName,
        orElse: () => Delegation(delegation: '', communes: []),
      );
      
      if (delegation.delegation.isNotEmpty) {
        availableCommunes = delegation.communes;
      }
    });
  }

  void _handleCommuneChange(String? communeName) {
    if (communeName == null) return;
    
    setState(() {
      selectedCommune = communeName;
      hospitals = [];
      
      final commune = availableCommunes.firstWhere(
        (c) => c.commune == communeName,
        orElse: () => Commune(commune: '', hopitaux: []),
      );
      
      if (commune.commune.isNotEmpty) {
        hospitals = commune.hopitaux;
      }
    });
  }
}