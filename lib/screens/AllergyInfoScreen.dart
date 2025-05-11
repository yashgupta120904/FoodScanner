import 'package:flutter/material.dart';

class AllergyInfoPopup extends StatelessWidget {
  final Function(String label, String imagePath)? onItemSelected;

  const AllergyInfoPopup({
    super.key,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        height: screenHeight * 0.5,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Ingredient...',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  itemCount: allergyItems.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenWidth > 600 ? 5 : 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    final item = allergyItems[index];
                    return _buildAllergyItem(
                      context,
                      item['label']!,
                      item['imagePath']!,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergyItem(
      BuildContext context, String label, String imagePath) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          if (onItemSelected != null) {
            onItemSelected!(label, imagePath);
          }
          Navigator.pop(context, {'label': label, 'imagePath': imagePath});
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Allergen items data
final List<Map<String, String>> allergyItems = [
  {'label': 'Milk', 'imagePath': 'Assets/Images/milk.png'},
  {'label': 'Eggs', 'imagePath': 'Assets/Images/egg.png'},
  {'label': 'Fish', 'imagePath': 'Assets/Images/fish.png'},
  {'label': 'Tree nut', 'imagePath': 'Assets/Images/cashew.png'},
  {'label': 'Shellfish', 'imagePath': 'Assets/Images/shellfish.png'},
  {'label': 'Peanuts', 'imagePath': 'Assets/Images/peanut.png'},
  {'label': 'Wheat', 'imagePath': 'Assets/Images/wheat.png'},
  {'label': 'Soybeans', 'imagePath': 'Assets/Images/s.png'},
  {'label': 'Meat', 'imagePath': 'Assets/Images/meat.png'},
];