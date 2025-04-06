import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/design_system.dart';
import '../../core/utils/responsive_helper.dart';
import 'auth/sign_in_screen.dart';
import 'main/main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AuthProvider _authProvider;
  late ApiService _apiService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<AuthProvider>();
    _apiService = ApiService.instance;
    _silentlyCheckAuth();
  }

  Future<void> _silentlyCheckAuth() async {
    try {
      final isAuthenticated = await _apiService.verifyAuthentication();
      if (isAuthenticated && mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } catch (e) {
      print('Silent auth check error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'À Vos Droits',
          style: TextStyle(
            color: Color(0xFF4CAF50),
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Color(0xFF4CAF50)),
            onPressed: () {
              // TODO: Implement language selection
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Color(0xFF4CAF50)),
            onPressed: () {
              Navigator.pushNamed(context, '/sign-in');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Green Header Section
            Container(
              color: const Color(0xFF4CAF50),
              padding: EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: isMobile ? 40.0 : 60.0,
              ),
              child: Column(
                children: [
                  Text(
                    'Bienvenue sur\nÀ Vos Droits',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 28 : 36,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Votre assistant personnel pour comprendre\net faire valoir vos droits',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 16 : 18,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Features Grid
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isMobile ? 2 : 4,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: 0.85,
                children: [
                  _buildFeatureCard(
                    icon: Icons.question_answer_outlined,
                    title: 'Questionnaire',
                    description: 'Découvrez vos droits en répondant à quelques questions simples',
                    onTap: () => Navigator.pushNamed(context, '/questionnaire'),
                  ),
                  _buildFeatureCard(
                    icon: Icons.menu_book_outlined,
                    title: 'Base de Droits',
                    description: 'Accédez à toutes les informations sur vos droits',
                    onTap: () => Navigator.pushNamed(context, '/rights-database'),
                  ),
                  _buildFeatureCard(
                    icon: Icons.description_outlined,
                    title: 'Courriers',
                    description: 'Générez automatiquement vos courriers administratifs',
                    onTap: () => Navigator.pushNamed(context, '/letters'),
                  ),
                  _buildFeatureCard(
                    icon: Icons.location_on_outlined,
                    title: 'Services',
                    description: 'Trouvez les structures adaptées près de chez vous',
                    onTap: () => Navigator.pushNamed(context, '/services'),
                  ),
                  _buildFeatureCard(
                    icon: Icons.chat_outlined,
                    title: 'Consultations',
                    description: 'Réservez une consultation avec un expert juridique',
                    onTap: () => Navigator.pushNamed(context, '/consultations'),
                  ),
                  _buildFeatureCard(
                    icon: Icons.folder_outlined,
                    title: 'Coffre-Fort',
                    description: 'Stockez et organisez vos documents importants',
                    onTap: () => Navigator.pushNamed(context, '/vault'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement emergency help
        },
        backgroundColor: Colors.red[600],
        icon: const Icon(Icons.emergency_outlined),
        label: const Text('Aide urgente'),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF4CAF50),
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 