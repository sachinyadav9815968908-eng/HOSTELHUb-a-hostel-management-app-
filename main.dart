import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

const Color kPrimary = Color(0xFF5B3FD0);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hostel Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5FA),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/hostel.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.60)),
          ),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.apartment, size: 80, color: Colors.white),
                SizedBox(height: 20),
                Text(
                  "Hostel Management",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Student & Warden Portal",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HostelBackground extends StatelessWidget {
  final Widget child;
  const HostelBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/hostel.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.45)),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: child,
        ),
      ),
    );
  }
}

InputDecoration appInput(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: Colors.white.withOpacity(0.95),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController rollController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  bool loading = false;

  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  Future<void> loginStudent() async {
    final roll = rollController.text.trim();
    final pass = passController.text.trim();

    if (roll.isEmpty || pass.isEmpty) {
      showMsg("Please enter roll number and password");
      return;
    }

    setState(() => loading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(roll)
          .get();

      if (!doc.exists) {
        showMsg("Student not found");
        setState(() => loading = false);
        return;
      }

      final data = doc.data()!;
      if ((data['password'] ?? '').toString() != pass) {
        showMsg("Wrong password");
        setState(() => loading = false);
        return;
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => StudentDashboard(studentData: data)),
      );
    } catch (e) {
      showMsg("Login error: $e");
    }

    if (mounted) setState(() => loading = false);
  }

  void loginAdmin() {
    if (rollController.text.trim() == "admin" &&
        passController.text.trim() == "warden123") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
      );
    } else {
      showMsg("Invalid admin credentials");
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    rollController.dispose();
    passController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HostelBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: 430,
              child: FadeTransition(
                opacity: _opacity,
                child: GlassCard(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          Icons.apartment,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Hostel Management System",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Student & Warden Portal",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: rollController,
                        decoration: appInput(
                          "Roll Number / Admin ID",
                          Icons.person_outline,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: passController,
                        obscureText: true,
                        decoration: appInput(
                          "Password",
                          Icons.lock_outline,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: kPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: loading ? null : loginStudent,
                          child: loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Student Login"),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: loginAdmin,
                          child: const Text("Admin Login"),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Student password = Room Number",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StudentDashboard extends StatefulWidget {
  final Map<String, dynamic> studentData;
  const StudentDashboard({super.key, required this.studentData});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  String selectedType = "Fan";
  final TextEditingController complaintController = TextEditingController();

  final List<String> complaintTypes = const [
    "Fan",
    "Cooler",
    "Light",
    "Water",
    "Cleaning",
    "Window/Lock",
    "Furniture",
    "Lift/WiFi",
    "Mess Complaint",
  ];

  String getPriority(String type) {
    if (type == "Water" || type == "Light") return "High";
    if (type == "Fan" || type == "Cooler" || type == "Lift/WiFi") {
      return "Medium";
    }
    return "Low";
  }

  Future<void> submitComplaint() async {
    final text = complaintController.text.trim();
    final room = widget.studentData['roomNo'].toString();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write complaint first")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('complaints').add({
      'room': room,
      'rollNo': widget.studentData['rollNo'],
      'studentName': widget.studentData['name'],
      'type': selectedType,
      'problem': text,
      'status': 'Pending',
      'priority': getPriority(selectedType),
      'time': Timestamp.now(),
      'adminRemark': '',
      'resolvedAt': null,
      'resolvedBy': '',
      'rating': 0,
      'review': '',
      'reviewGiven': false,
    });

    complaintController.clear();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Complaint submitted")),
    );
  }

  Future<void> submitReview({
    required String complaintId,
    required int rating,
    required String review,
  }) async {
    await FirebaseFirestore.instance
        .collection('complaints')
        .doc(complaintId)
        .update({
      'rating': rating,
      'review': review.trim(),
      'reviewGiven': true,
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Review submitted successfully")),
    );
  }

  void showReviewDialog(String complaintId) {
    int selectedRating = 5;
    final reviewCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Give Feedback"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Rate complaint resolution:",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final star = index + 1;
                    return IconButton(
                      onPressed: () {
                        setDialogState(() => selectedRating = star);
                      },
                      icon: Icon(
                        Icons.star,
                        color: star <= selectedRating
                            ? Colors.amber
                            : Colors.grey.shade400,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: reviewCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Write your review",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              FilledButton(
                onPressed: () async {
                  await submitReview(
                    complaintId: complaintId,
                    rating: selectedRating,
                    review: reviewCtrl.text,
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text("Submit"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    complaintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.studentData['roomNo'].toString();
    final rollNo = widget.studentData['rollNo'].toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            proCard(
              title: "Student Details",
              icon: Icons.badge_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  infoRow("Name", "${widget.studentData['name']}"),
                  infoRow("Roll Number", "${widget.studentData['rollNo']}"),
                  infoRow("Room Number", "${widget.studentData['roomNo']}"),
                ],
              ),
            ),
            const SizedBox(height: 16),
            proCard(
              title: "Mess Bill",
              icon: Icons.receipt_long_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  infoRow("Old Bill", "₹${widget.studentData['oldBill']}"),
                  infoRow("Current Bill", "₹${widget.studentData['currentBill']}"),
                  infoRow("Total Bill", "₹${widget.studentData['total']}"),
                ],
              ),
            ),
            const SizedBox(height: 16),
            proCard(
              title: "Bill History",
              icon: Icons.history,
              child: SizedBox(
                height: 260,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('bill_history')
                      .where('rollNo', isEqualTo: rollNo)
                      .orderBy('updatedAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: Text("No data received"));
                    }

                    final docs = snapshot.data!.docs;

                    if (docs.isEmpty) {
                      return const Center(child: Text("No bill history found"));
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (_, i) {
                        final d = docs[i].data() as Map<String, dynamic>;
                        return Card(
                          elevation: 0,
                          color: const Color(0xFFF7F7FC),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFEAE7FF),
                              child: Icon(Icons.receipt_long, color: kPrimary),
                            ),
                            title: Text("Total: ₹${d['total']}"),
                            subtitle: Text(
                              "Old: ₹${d['oldBill']} | Current: ₹${d['currentBill']}",
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            proCard(
              title: "Today's Mess Menu",
              icon: Icons.restaurant_menu,
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('mess_menu')
                    .doc('today')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: Text("No menu data"));
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>?;

                  if (data == null) {
                    return const Text("Menu not available");
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      infoRow("Breakfast", "${data['breakfast'] ?? ''}"),
                      infoRow("Lunch", "${data['lunch'] ?? ''}"),
                      infoRow("Dinner", "${data['dinner'] ?? ''}"),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            proCard(
              title: "Register Complaint",
              icon: Icons.edit_note_outlined,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items: complaintTypes
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedType = value!);
                    },
                    decoration: appInput(
                      "Complaint Type",
                      Icons.category_outlined,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: complaintController,
                    maxLines: 3,
                    decoration: appInput(
                      "Describe your complaint",
                      Icons.report_problem_outlined,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      label: Text("Priority: ${getPriority(selectedType)}"),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: submitComplaint,
                      child: const Text("Submit Complaint"),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            proCard(
              title: "My Complaints",
              icon: Icons.history,
              child: SizedBox(
                height: 420,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('complaints')
                      .where('room', isEqualTo: room)
                      .orderBy('time', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: Text("No data received"));
                    }

                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return const Center(child: Text("No complaints found"));
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (_, i) {
                        final d = docs[i].data() as Map<String, dynamic>;

                        return Card(
                          elevation: 0,
                          color: const Color(0xFFF7F7FC),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFFEAE7FF),
                                    child: Icon(
                                      Icons.report_problem,
                                      color: kPrimary,
                                    ),
                                  ),
                                  title: Text("${d['type']} • ${d['status']}"),
                                  subtitle: Text(
                                    "${d['problem']}\nPriority: ${d['priority']}",
                                  ),
                                  isThreeLine: true,
                                ),
                                if ((d['adminRemark'] ?? '')
                                    .toString()
                                    .isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      "Admin Remark: ${d['adminRemark']}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                if (d['resolvedBy'] != null &&
                                    d['resolvedBy'].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text("Resolved By: ${d['resolvedBy']}"),
                                  ),
                                if (d['resolvedAt'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      "Resolved: ${d['resolvedAt'] is Timestamp ? (d['resolvedAt'] as Timestamp).toDate().toString() : d['resolvedAt'].toString()}",
                                    ),
                                  ),
                                if (d['rating'] != null &&
                                    ((d['rating'] as num).toInt()) > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Row(
                                      children: [
                                        const Text(
                                          "Your Rating: ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        ...List.generate(
                                          (d['rating'] as num).toInt(),
                                          (_) => const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if ((d['review'] ?? '').toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text("Your Review: ${d['review']}"),
                                  ),
                                const SizedBox(height: 8),
                                if (d['status'] == 'Resolved' &&
                                    (d['reviewGiven'] ?? false) == false)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: FilledButton.icon(
                                      onPressed: () =>
                                          showReviewDialog(docs[i].id),
                                      icon: const Icon(Icons.rate_review),
                                      label: const Text("Give Review"),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
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
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin Dashboard"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Overview"),
              Tab(text: "Students"),
              Tab(text: "Complaints"),
              Tab(text: "Menu"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text("Logout"),
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            AdminOverviewTab(),
            StudentsTab(),
            ComplaintsTab(),
            AdminMessMenuTab(),
          ],
        ),
      ),
    );
  }
}

class AdminOverviewTab extends StatelessWidget {
  const AdminOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('complaints')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, complaintSnap) {
        if (complaintSnap.hasError) {
          return Center(
            child: Text("Error: ${complaintSnap.error}"),
          );
        }

        if (complaintSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!complaintSnap.hasData) {
          return const Center(child: Text("No data received"));
        }

        final complaints = complaintSnap.data!.docs;

        int pending = 0;
        int inProgress = 0;
        int resolved = 0;
        int totalComplaints = complaints.length;
        int messComplaints = 0;
        int totalRating = 0;
        int ratingCount = 0;

        Map<String, int> categoryCount = {};

        for (final doc in complaints) {
          final data = doc.data() as Map<String, dynamic>;
          final status = (data['status'] ?? 'Pending').toString();
          final type = (data['type'] ?? 'Unknown').toString();
          final rating = ((data['rating'] ?? 0) as num).toInt();

          if (status == "Pending") {
            pending++;
          } else if (status == "In Progress") {
            inProgress++;
          } else if (status == "Resolved") {
            resolved++;
          }

          if (type == "Mess Complaint") {
            messComplaints++;
          }

          categoryCount[type] = (categoryCount[type] ?? 0) + 1;

          if (rating > 0) {
            totalRating += rating;
            ratingCount++;
          }
        }

        final double averageRating =
            ratingCount == 0 ? 0.0 : totalRating / ratingCount;

        String topComplaintType = "N/A";
        int topCount = 0;

        categoryCount.forEach((key, value) {
          if (value > topCount) {
            topCount = value;
            topComplaintType = key;
          }
        });

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: dashboardStatCard(
                      "Pending Alerts",
                      pending.toString(),
                      Icons.notifications_active,
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: dashboardStatCard(
                      "In Progress",
                      inProgress.toString(),
                      Icons.build_circle,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: dashboardStatCard(
                      "Resolved",
                      resolved.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: dashboardStatCard(
                      "Total Complaints",
                      totalComplaints.toString(),
                      Icons.list_alt,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: dashboardStatCard(
                      "Mess Complaints",
                      messComplaints.toString(),
                      Icons.restaurant,
                      Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: dashboardStatCard(
                      "Avg Rating",
                      averageRating.toStringAsFixed(1),
                      Icons.star,
                      Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              proCard(
                title: "Latest Complaint Alert",
                icon: Icons.warning_amber_rounded,
                child: complaints.isEmpty
                    ? const Text("No complaints yet")
                    : _latestComplaintCard(
                        complaints.first.data() as Map<String, dynamic>,
                      ),
              ),
              const SizedBox(height: 16),
              proCard(
                title: "Pending Complaints",
                icon: Icons.error_outline,
                child: SizedBox(
                  height: 420,
                  child: pending == 0
                      ? const Center(
                          child: Text("No pending complaints"),
                        )
                      : ListView(
                          children: complaints.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return (data['status'] ?? 'Pending') == "Pending";
                          }).map((doc) {
                            final d = doc.data() as Map<String, dynamic>;
                            return Card(
                              color: const Color(0xFFFFEBEE),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.notification_important,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  "Room ${d['room']} • ${d['type']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "${d['problem']}\nPriority: ${d['priority']}",
                                ),
                                isThreeLine: true,
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              proCard(
                title: "Report Summary",
                icon: Icons.analytics_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    infoRow("Top Complaint Type", topComplaintType),
                    infoRow("Total Complaints", totalComplaints.toString()),
                    infoRow("Resolved Complaints", resolved.toString()),
                    infoRow("Average Rating", averageRating.toStringAsFixed(1)),
                    infoRow("Mess Complaints", messComplaints.toString()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _latestComplaintCard(Map<String, dynamic> d) {
    final status = (d['status'] ?? 'Pending').toString();
    final isPending = status == "Pending";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPending ? const Color(0xFFFFEBEE) : const Color(0xFFF7F7FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending ? Colors.red : Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: isPending ? Colors.red : Colors.orange,
            child: const Icon(Icons.campaign, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Room ${d['room']} • ${d['type']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text("${d['problem']}"),
                const SizedBox(height: 6),
                Text(
                  "Status: $status",
                  style: TextStyle(
                    color: isPending ? Colors.red : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StudentsTab extends StatelessWidget {
  const StudentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: proCard(
        title: "All Students",
        icon: Icons.groups_outlined,
        child: SizedBox(
          height: 600,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('students').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return const Center(child: Text("No data received"));
              }

              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(child: Text("No students found"));
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final d = docs[i].data() as Map<String, dynamic>;
                  final roll = d['rollNo'].toString();

                  return Card(
                    elevation: 0,
                    color: const Color(0xFFF7F7FC),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFEAE7FF),
                        child: Icon(Icons.person, color: kPrimary),
                      ),
                      title: Text("${d['name']}"),
                      subtitle: Text(
                        "Roll: ${d['rollNo']} | Room: ${d['roomNo']}\nOld Bill: ₹${d['oldBill']} | Current Bill: ₹${d['currentBill']} | Total: ₹${d['total']}",
                      ),
                      isThreeLine: true,
                      trailing: ElevatedButton(
                        child: const Text("Update Bill"),
                        onPressed: () {
                          final oldBillCtrl = TextEditingController(
                            text: (d['oldBill'] ?? 0).toString(),
                          );
                          final currentBillCtrl = TextEditingController(
                            text: (d['currentBill'] ?? 0).toString(),
                          );

                          showDialog(
                            context: context,
                            builder: (_) => StatefulBuilder(
                              builder: (context, setDialogState) {
                                final totalBill =
                                    (int.tryParse(oldBillCtrl.text.trim()) ?? 0) +
                                        (int.tryParse(
                                              currentBillCtrl.text.trim(),
                                            ) ??
                                            0);

                                return AlertDialog(
                                  title: const Text("Update Mess Bill"),
                                  content: SizedBox(
                                    width: 350,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: oldBillCtrl,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: "Old Bill / Pending Bill",
                                          ),
                                          onChanged: (_) => setDialogState(() {}),
                                        ),
                                        const SizedBox(height: 12),
                                        TextField(
                                          controller: currentBillCtrl,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: "Current Bill",
                                          ),
                                          onChanged: (_) => setDialogState(() {}),
                                        ),
                                        const SizedBox(height: 16),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Total Bill: ₹$totalBill",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cancel"),
                                    ),
                                    FilledButton(
                                      onPressed: () async {
                                        final oldBill =
                                            int.tryParse(oldBillCtrl.text.trim()) ??
                                                0;
                                        final currentBill =
                                            int.tryParse(currentBillCtrl.text.trim()) ??
                                                0;
                                        final totalBill = oldBill + currentBill;

                                        await FirebaseFirestore.instance
                                            .collection('students')
                                            .doc(roll)
                                            .update({
                                          'oldBill': oldBill,
                                          'currentBill': currentBill,
                                          'total': totalBill,
                                        });

                                        await FirebaseFirestore.instance
                                            .collection('bill_history')
                                            .add({
                                          'rollNo': d['rollNo'],
                                          'name': d['name'],
                                          'roomNo': d['roomNo'],
                                          'oldBill': oldBill,
                                          'currentBill': currentBill,
                                          'total': totalBill,
                                          'updatedAt': Timestamp.now(),
                                        });

                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: const Text("Save"),
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class ComplaintsTab extends StatelessWidget {
  const ComplaintsTab({super.key});

  Future<void> updateStatus({
    required String id,
    required String status,
    required String adminRemark,
  }) async {
    final Map<String, dynamic> data = {
      'status': status,
      'adminRemark': adminRemark.trim(),
    };

    if (status == "Resolved") {
      data['resolvedAt'] = Timestamp.now();
      data['resolvedBy'] = "Warden";
    }

    await FirebaseFirestore.instance
        .collection('complaints')
        .doc(id)
        .update(data);
  }

  Future<void> deleteComplaint(String id) async {
    await FirebaseFirestore.instance.collection('complaints').doc(id).delete();
  }

  void showStatusDialog(
    BuildContext context,
    String complaintId,
    String newStatus,
  ) {
    final remarkCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Update Status: $newStatus"),
        content: TextField(
          controller: remarkCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: "Admin Remark",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () async {
              await updateStatus(
                id: complaintId,
                status: newStatus,
                adminRemark: remarkCtrl.text,
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Color statusColor(String status) {
    if (status == "Pending") return Colors.red;
    if (status == "In Progress") return Colors.orange;
    if (status == "Resolved") return Colors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: proCard(
        title: "All Complaints",
        icon: Icons.report_problem_outlined,
        child: SizedBox(
          height: 600,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('complaints')
                .orderBy('time', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return const Center(child: Text("No data received"));
              }

              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(child: Text("No complaints found"));
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final d = docs[i].data() as Map<String, dynamic>;
                  final currentStatus = "${d['status']}";

                  return Card(
                    elevation: 0,
                    color: const Color(0xFFF7F7FC),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Room ${d['room']} • ${d['type']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text("${d['problem']}"),
                          const SizedBox(height: 6),
                          Text("Priority: ${d['priority']}"),
                          Text(
                            "Status: $currentStatus",
                            style: TextStyle(
                              color: statusColor(currentStatus),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if ((d['adminRemark'] ?? '').toString().isNotEmpty)
                            Text(
                              "Remark: ${d['adminRemark']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if ((d['reviewGiven'] ?? false) == true) ...[
                            const SizedBox(height: 6),
                            Text("Student Rating: ${d['rating']} / 5"),
                            Text("Student Review: ${d['review']}"),
                          ],
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilledButton(
                                onPressed: () =>
                                    showStatusDialog(context, docs[i].id, "Pending"),
                                child: const Text("Pending"),
                              ),
                              FilledButton(
                                onPressed: () => showStatusDialog(
                                  context,
                                  docs[i].id,
                                  "In Progress",
                                ),
                                child: const Text("In Progress"),
                              ),
                              FilledButton(
                                onPressed: () => showStatusDialog(
                                  context,
                                  docs[i].id,
                                  "Resolved",
                                ),
                                child: const Text("Resolved"),
                              ),
                              OutlinedButton(
                                onPressed: () => deleteComplaint(docs[i].id),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class AdminMessMenuTab extends StatefulWidget {
  const AdminMessMenuTab({super.key});

  @override
  State<AdminMessMenuTab> createState() => _AdminMessMenuTabState();
}

class _AdminMessMenuTabState extends State<AdminMessMenuTab> {
  final TextEditingController breakfastCtrl = TextEditingController();
  final TextEditingController lunchCtrl = TextEditingController();
  final TextEditingController dinnerCtrl = TextEditingController();

  bool loaded = false;

  Future<void> loadMenu() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('mess_menu')
          .doc('today')
          .get();

      final data = doc.data();
      if (data != null) {
        breakfastCtrl.text = (data['breakfast'] ?? '').toString();
        lunchCtrl.text = (data['lunch'] ?? '').toString();
        dinnerCtrl.text = (data['dinner'] ?? '').toString();
      }
    } catch (e) {
      debugPrint("Menu load error: $e");
    }

    if (mounted) {
      setState(() => loaded = true);
    }
  }

  Future<void> saveMenu() async {
    await FirebaseFirestore.instance.collection('mess_menu').doc('today').set({
      'breakfast': breakfastCtrl.text.trim(),
      'lunch': lunchCtrl.text.trim(),
      'dinner': dinnerCtrl.text.trim(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Mess menu updated")),
    );
  }

  @override
  void initState() {
    super.initState();
    loadMenu();
  }

  @override
  void dispose() {
    breakfastCtrl.dispose();
    lunchCtrl.dispose();
    dinnerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: proCard(
        title: "Update Today's Mess Menu",
        icon: Icons.restaurant_menu,
        child: Column(
          children: [
            TextField(
              controller: breakfastCtrl,
              decoration: const InputDecoration(labelText: "Breakfast"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lunchCtrl,
              decoration: const InputDecoration(labelText: "Lunch"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dinnerCtrl,
              decoration: const InputDecoration(labelText: "Dinner"),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: saveMenu,
                child: const Text("Save Menu"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget dashboardStatCard(
  String title,
  String value,
  IconData icon,
  Color color,
) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 16),
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    ),
  );
}

Widget proCard({
  required String title,
  required IconData icon,
  required Widget child,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 12,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: kPrimary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}

Widget infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(
            "$label:",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
