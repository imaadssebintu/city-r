import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_html/flutter_html.dart';

// 1. CHANGE THIS to your Computer's IP (e.g. 'http://192.168.1.15:3000') to test on your iPhone!
const String API_BASE_URL = 'http://localhost:3000';

void main() {
  runApp(const CityRApp());
}

class CityRApp extends StatelessWidget {
  const CityRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'City-R | Premium Car Marketplace',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D4ED8)),
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> cars = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCars();
  }

  Future<void> fetchCars() async {
    try {
      final response = await http.get(Uri.parse('$API_BASE_URL/api/cars'));
      if (response.statusCode == 200) {
        setState(() {
          cars = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      debugPrint('Error fetching cars: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 1024;

          return SingleChildScrollView(
            child: Column(
              children: [
                const TopNavBar(),
                const AppHeader(),
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1440),
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 24 : 16,
                      vertical: 32,
                    ),
                    child: isDesktop
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Sidebar Left (220px)
                              const SizedBox(
                                width: 220,
                                child: FilterSidebar(),
                              ),
                              const SizedBox(width: 32),
                              // Middle Column
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildLatestCarsHub(),
                                    const SizedBox(height: 24),
                                    const SortBar(),
                                    const SizedBox(height: 16),
                                    if (isLoading)
                                      const CircularProgressIndicator()
                                    else if (cars.isEmpty)
                                      const Text('No cars found.')
                                    else
                                      GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: cars.length,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              crossAxisSpacing: 20,
                                              mainAxisSpacing: 20,
                                              childAspectRatio: 0.82,
                                            ),
                                        itemBuilder: (context, index) =>
                                            CarCard(car: cars[index]),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 32),
                              // Sidebar Right (220px)
                              const SizedBox(
                                width: 220,
                                child: FeaturedSidebar(),
                              ),
                            ],
                          )
                        : Column(
                            // Mobile ordering: Header Hub -> Left Sidebar -> Right Sidebar -> Sort/Content
                            children: [
                              _buildLatestCarsHub(),
                              const SizedBox(height: 16),
                              const FilterSidebar(),
                              const SizedBox(height: 24),
                              const FeaturedSidebar(),
                              const SizedBox(height: 24),
                              const SortBar(),
                              const SizedBox(height: 16),
                              if (isLoading)
                                const CircularProgressIndicator()
                              else if (cars.isEmpty)
                                const Text('No cars found.')
                              else
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: cars.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount:
                                            constraints.maxWidth > 700 ? 2 : 1,
                                        crossAxisSpacing: 20,
                                        mainAxisSpacing: 20,
                                        childAspectRatio: 0.82,
                                      ),
                                  itemBuilder: (context, index) =>
                                      CarCard(car: cars[index]),
                                ),
                            ],
                          ),
                  ),
                ),
                const AppFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLatestCarsHub() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: Color(0xFF1D4ED8), size: 20),
              SizedBox(width: 10),
              Text(
                'Latest Cars for Sale',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D4ED8),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Color(0xFF64748B), size: 16),
              SizedBox(width: 6),
              Text(
                'Last updated: Today',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- TOP NAV BAR ---
class TopNavBar extends StatelessWidget {
  const TopNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1440),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Wrap(
            spacing: 20,
            runSpacing: 10,
            children: [
              _navLink('List a Vehicle FREE', Icons.tag, isPrimary: true),
              _navLink('Edit / Remove', Icons.edit),
              _navLink('Request a Car', Icons.directions_car),
              _navLink('Financing', Icons.payments_outlined),
              _navLink('Support', Icons.headset_mic_outlined),
              _navLink('Dealer Login', Icons.person_outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navLink(String text, IconData icon, {bool isPrimary = false}) {
    return HoverableLink(
      isPrimary: isPrimary,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// --- HOVER HELPER ---
class HoverableLink extends StatefulWidget {
  final Widget child;
  final bool isPrimary;
  final VoidCallback? onTap;

  const HoverableLink({
    super.key,
    required this.child,
    this.isPrimary = false,
    this.onTap,
  });

  @override
  State<HoverableLink> createState() => _HoverableLinkState();
}

class _HoverableLinkState extends State<HoverableLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color defaultColor = widget.isPrimary
        ? const Color(0xFF1D4ED8)
        : const Color(0xFF64748B);
    final Color hoverColor = const Color(0xFF1D4ED8);
    final Color currentColor = _isHovered ? hoverColor : defaultColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: IconTheme(
          data: IconThemeData(color: currentColor, size: 16),
          child: DefaultTextStyle(
            style: TextStyle(
              color: currentColor,
              fontFamily: GoogleFonts.inter().fontFamily,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// --- APP HEADER ---
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 1024;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1440),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildBranding(true),
                        const SizedBox(width: 40),
                        const Expanded(child: SearchForm()),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildBranding(false),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.search),
                          label: const Text('Search Listings'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 44),
                            backgroundColor: const Color(0xFFF1F5F9),
                            foregroundColor: const Color(0xFF0F172A),
                            elevation: 0,
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranding(bool isDesktop) {
    return Column(
      crossAxisAlignment: isDesktop
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        // Logo with "negative margins" effect
        SizedBox(
          width: 220,
          height: 50,
          child: OverflowBox(
            maxWidth: 320,
            maxHeight: 120,
            child: Transform.translate(
              offset: const Offset(0, -6),
              child: Image.network(
                '$API_BASE_URL/static/logo.png',
                width: 320,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const Text(
                  'CITY-R',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            'WE BUY & SELL USED AND NEW CARS',
            style: TextStyle(
              fontSize: 9,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

// --- SEARCH FORM ---
class SearchForm extends StatefulWidget {
  const SearchForm({super.key});

  @override
  State<SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  String? selectedMake;
  String? selectedBody;
  String? selectedMinPrice;
  String? selectedMaxPrice;
  String? selectedFuel;
  String? selectedYearFrom;
  String? selectedYearTo;
  String? selectedTransmission;
  final TextEditingController _keywordsController = TextEditingController();

  final List<String> makes = [
    'BMW',
    'Mercedes-Benz',
    'Audi',
    'Porsche',
    'Tesla',
    'Volkswagen',
    'Toyota',
    'Dacia',
    'Skoda',
    'Nissan',
    'Mazda',
    'Hyundai',
    'Kia',
    'Volvo',
    'Ford',
    'Range Rover',
  ];

  final List<String> bodyTypes = [
    'Sedan',
    'SUV',
    'Coupe',
    'Estate',
    'Hatchback',
    'Convertible',
    'Pickup',
    'Van',
  ];

  final List<String> prices = [
    'UGX 1,000',
    'UGX 5,000',
    'UGX 10,000',
    'UGX 25,000',
    'UGX 50,000',
    'UGX 100,000',
  ];

  final List<String> fuelTypes = ['Petrol', 'Diesel', 'Electric', 'Hybrid'];
  final List<String> years = List.generate(10, (i) => (2015 + i).toString());
  final List<String> transmissions = ['Automatic', 'Manual', 'CVT'];

  @override
  void dispose() {
    _keywordsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 1024;
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = isDesktop
            ? 5
            : (constraints.maxWidth > 700 ? 3 : 2);
        const double spacing = 8.0;
        const double targetHeight = 40.0;
        double childAspectRatio =
            (constraints.maxWidth - (crossAxisCount - 1) * spacing) /
            crossAxisCount /
            targetHeight;

        return Column(
          children: [
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              children: [
                _buildDropdown(
                  'Any Make',
                  makes,
                  selectedMake,
                  (val) => setState(() => selectedMake = val),
                ),
                _buildDropdown(
                  'Any Body Type',
                  bodyTypes,
                  selectedBody,
                  (val) => setState(() => selectedBody = val),
                ),
                _buildDropdown(
                  'Any Min Price',
                  prices,
                  selectedMinPrice,
                  (val) => setState(() => selectedMinPrice = val),
                ),
                _buildDropdown(
                  'Any Max Price',
                  prices,
                  selectedMaxPrice,
                  (val) => setState(() => selectedMaxPrice = val),
                ),
                _buildInput('Keywords... e.g. panoramic'),
                _buildDropdown(
                  'Any Fuel Type',
                  fuelTypes,
                  selectedFuel,
                  (val) => setState(() => selectedFuel = val),
                ),
                _buildDropdown(
                  'Year From',
                  years,
                  selectedYearFrom,
                  (val) => setState(() => selectedYearFrom = val),
                ),
                _buildDropdown(
                  'Year To',
                  years,
                  selectedYearTo,
                  (val) => setState(() => selectedYearTo = val),
                ),
                _buildDropdown(
                  'Any Transmission',
                  transmissions,
                  selectedTransmission,
                  (val) => setState(() => selectedTransmission = val),
                ),
                Center(
                  child: SizedBox(
                    height: 36, // h-9 from web
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Implement search logic
                      },
                      icon: const Icon(Icons.search, size: 16),
                      label: const Text('Search'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D4ED8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.directions_car, size: 16, color: Color(0xFF1D4ED8)),
                SizedBox(width: 8),
                Text(
                  '8,421 vehicles for sale',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdown(
    String hint,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            overflow: TextOverflow.ellipsis,
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.expand_more,
            size: 16,
            color: Color(0xFF64748B),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildInput(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: _keywordsController,
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

// --- SIDEBARS ---
class FilterSidebar extends StatelessWidget {
  const FilterSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAccordion('Browse by Body Type', Icons.directions_car, [
          _buildFilterItem('Sedan', '185'),
          _buildFilterItem('SUV', '390'),
          _buildFilterItem('Hatchback', '142'),
          _buildFilterItem('Estate', '67'),
          _buildFilterItem('Coupe', '48'),
          _buildFilterItem('Convertible', '13'),
          _buildFilterItem('Pickup', '29'),
          _buildFilterItem('Van', '54'),
          _buildFilterItem('Electric', '37'),
          _buildFilterItem('Hybrid', '62'),
        ]),
        const SizedBox(height: 20),
        _buildAccordion('Browse by City', Icons.location_on, [
          _buildFilterItem('Bucharest', '412'),
          _buildFilterItem('Cluj-Napoca', '98'),
          _buildFilterItem('Timisoara', '74'),
          _buildFilterItem('Iasi', '55'),
          _buildFilterItem('Constanta', '43'),
          _buildFilterItem('Brasov', '38'),
        ]),
      ],
    );
  }

  Widget _buildAccordion(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF1D4ED8), size: 18),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFilterItem(String title, String count) {
    return HoverableLink(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              count,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}

class FeaturedSidebar extends StatelessWidget {
  const FeaturedSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFF59E0B), width: 2),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star, color: Color(0xFFF59E0B), size: 18),
                    SizedBox(width: 10),
                    Text(
                      'Featured Listing',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
              ),
              Image.network(
                'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=400&q=80',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BMW M5 Competition',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '2023 · 8,200 km · Petrol',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'UGX 89,500',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildSidebarAccordion('Cars by Make', Icons.flag, [
          _buildFilterItem('Toyota', '215'),
          _buildFilterItem('Volkswagen', '184'),
          _buildFilterItem('BMW', '97'),
          _buildFilterItem('Mercedes-Benz', '88'),
          _buildFilterItem('Audi', '72'),
          _buildFilterItem('Skoda', '65'),
          _buildFilterItem('Dacia', '59'),
          _buildFilterItem('Ford', '48'),
          _buildFilterItem('Tesla', '14'),
          _buildFilterItem('Porsche', '9'),
        ]),
      ],
    );
  }

  Widget _buildSidebarAccordion(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF1D4ED8), size: 18),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFilterItem(String title, String count) {
    return HoverableLink(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              count,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- SORT BAR ---
class SortBar extends StatelessWidget {
  const SortBar({super.key});

  @override
  Widget build(BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width > 768;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                'Sort:',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  children: [
                    Text(
                      'Newest First',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              ),
            ],
          ),
          if (isWide)
            Row(
              children: [
                _tabItem('All Cars', true),
                const SizedBox(width: 20),
                _tabItem('New Cars (12)', false),
                const SizedBox(width: 20),
                _tabItem('Used Cars', false),
              ],
            ),
        ],
      ),
    );
  }

  Widget _tabItem(String title, bool active) {
    Widget content = Container(
      padding: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: active ? const Color(0xFF1D4ED8) : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );

    if (active) {
      return DefaultTextStyle(
        style: const TextStyle(color: Color(0xFF1D4ED8)),
        child: content,
      );
    }

    return HoverableLink(child: content);
  }
}

// --- CAR CARD ---
class CarCard extends StatefulWidget {
  final dynamic car;
  const CarCard({super.key, required this.car});

  @override
  State<CarCard> createState() => _CarCardState();
}

class _CarCardState extends State<CarCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            if (_isHovered) ...[
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 10),
                spreadRadius: -3,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 4),
                spreadRadius: -4,
              ),
            ],
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsScreen(carId: widget.car['ID']),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Image.network(
                      widget.car['ImageURL'],
                      height: double.infinity,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    if (widget.car['Badge'] != null &&
                        widget.car['Badge'] != "")
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getBadgeColor(widget.car['Badge']),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.car['Badge'].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.car['Year']} · ${widget.car['Make']}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.car['Model'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'UGX ${widget.car['Price']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _infoIcon(
                          Icons.settings_outlined,
                          widget.car['Transmission'],
                        ),
                        const SizedBox(width: 12),
                        _infoIcon(
                          Icons.local_gas_station_outlined,
                          widget.car['Fuel'],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.palette,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.car['Color'],
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Details >',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D4ED8),
                        decoration: _isHovered
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBadgeColor(String badge) {
    if (badge == "New") return const Color(0xFF059669);
    if (badge == "Hot Deal") return const Color(0xFFF59E0B);
    return const Color(0xFF1D4ED8);
  }

  Widget _infoIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 13, color: const Color(0xFF64748B)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}

// --- APP FOOTER ---
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 32,
                runSpacing: 16,
                children: [
                  _footerLink('Home'),
                  _footerLink('All Cars'),
                  _footerLink('Sell Your Car'),
                  _footerLink('Financing'),
                  _footerLink('Support'),
                  _footerLink('About Us'),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                '© 2024 City-R SRL. Romania\'s Premium Car Marketplace. All rights reserved.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerLink(String label) {
    return HoverableLink(
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// --- DETAILS SCREEN ---
class DetailsScreen extends StatefulWidget {
  final int carId;
  const DetailsScreen({super.key, required this.carId});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  dynamic car;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$API_BASE_URL/api/cars/${widget.carId}'),
      );
      if (response.statusCode == 200) {
        setState(() {
          car = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isLoading ? 'Loading...' : '${car['Make']} ${car['Model']}',
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    car['ImageURL'],
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${car['Year']} Models',
                                  style: const TextStyle(
                                    color: Color(0xFF1D4ED8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${car['Make']} ${car['Model']}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'UGX ${car['Price']}',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1D4ED8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Html(
                          data:
                              car['Description'] ?? 'No description available.',
                          style: {
                            "body": Style(
                              fontSize: FontSize(14),
                              color: const Color(0xFF334155),
                              lineHeight: LineHeight.em(1.6),
                            ),
                          },
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'Specifications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _specRow('Engine', car['Engine']),
                        _specRow('Transmission', car['Transmission']),
                        _specRow('Mileage', '${car['Mileage']} km'),
                        _specRow('Fuel Type', car['Fuel']),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1D4ED8),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Contact Dealer',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _specRow(String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B))),
          Text(
            value?.toString() ?? 'N/A',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
