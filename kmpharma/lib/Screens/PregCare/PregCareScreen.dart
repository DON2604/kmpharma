import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PregnancyCareScreen extends StatefulWidget {
  const PregnancyCareScreen({super.key});

  @override
  State<PregnancyCareScreen> createState() => _PregnancyCareScreenState();
}

class _PregnancyCareScreenState extends State<PregnancyCareScreen> {
  List<Map<String, String>> reminders = [
    {"title": "Take folic acid tablet", "time": "9:00 AM"},
    {"title": "Drink water (2 glasses)", "time": "11:30 AM"},
    {"title": "Evening walk for 20 mins", "time": "6:00 PM"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF5F8),

      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        elevation: 0,
        title: const Text(
          "Pregnancy Care",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        onPressed: () {},
        child: const Icon(Icons.mic, size: 30, color: Colors.white),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dailyTipCard(),
            const SizedBox(height: 18),
            _sectionTitle("Mother & Baby Reminders"),
            _reminderList(),
            const SizedBox(height: 15),
            _addReminderButton(),
            const SizedBox(height: 24),
            _sectionTitle("AI Pregnancy Companion"),
            _aiCompanionCard(), // 👈 NEW
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ------------------ Daily Tip Card ------------------
  Widget _dailyTipCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.pink.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: Colors.white, size: 40),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              "Daily Tip: Stay hydrated and eat small meals throughout the day to avoid nausea.",
              style: TextStyle(
                color: Colors.pink.shade900,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ Section Title ------------------
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.pink.shade900,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ------------------ Add Reminder Button ------------------
  Widget _addReminderButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Add Reminder",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () {},
        ),
      ),
    );
  }

  // ------------------ Reminder List ------------------
  Widget _reminderList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reminders.length,
      itemBuilder: (ctx, i) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminders[i]["title"]!,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.pink.shade900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    reminders[i]["time"]!,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () {
                  setState(() {
                    reminders.removeAt(i);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------ AI Companion Card (NEW) ------------------
  Widget _aiCompanionCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.pink.shade300, Colors.pink.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.support_agent,
              color: Colors.pinkAccent,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Have a doubt or feeling uncertain?\nChat with your AI pregnancy companion anytime.",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.pinkAccent,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _openAiCompanion,
            child: const Text(
              "Ask",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ Open AI Companion (dummy link) ------------------
  Future<void> _openAiCompanion() async {
    // TODO: replace this with your own AI chat screen or API page
    final uri = Uri.parse("https://example.com/ai-pregnancy-companion");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open AI companion.")),
      );
    }
  }
}
