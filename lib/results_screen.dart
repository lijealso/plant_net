import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  final Map<String, dynamic> identificationData;

  const ResultsScreen({super.key, required this.identificationData});

  @override
  Widget build(BuildContext context) {
    final results = identificationData['results'] as List;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
      ),
      body: results.isEmpty
          ? const Center(child: Text('Sem resultados.'))
          : ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = results[index];
                final species = result['species'];
                final images = result['images'] as List;
                final score = (result['score'] * 100).toStringAsFixed(2);

                return Card(
                  margin: const EdgeInsets.all(10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}. ${species['scientificName']}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Probabilidade: $score%',
                          style: const TextStyle(
                              fontSize: 16, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 16),
                        if (species['commonNames'] != null &&
                            (species['commonNames'] as List).isNotEmpty) ...[
                          const Text(
                            'Nomes comuns:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: (species['commonNames'] as List)
                                .map((name) => Chip(label: Text(name)))
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (images.isNotEmpty) ...[
                          const Text(
                            'Imagens relacionadas:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: images.length,
                              itemBuilder: (context, imgIndex) {
                                final imageUrl = images[imgIndex]['url']['m'];
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(right: 8.0),
                                  child: Image.network(imageUrl,
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100),
                                );
                              },
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}