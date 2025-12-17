import 'package:flutter/material.dart';
import 'package:kmpharma/constants.dart';
import 'package:kmpharma/services/medicine_service.dart';
import 'widgets/ordered_medicines_card.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final MedicineService _medicineService = MedicineService();
  bool _isLoadingOrders = false;
  List<Map<String, dynamic>> _orderedMedicines = [];

  @override
  void initState() {
    super.initState();
    _loadOrderedMedicines();
  }

  Future<void> _loadOrderedMedicines() async {
    setState(() {
      _isLoadingOrders = true;
    });

    try {
      final orders = await _medicineService.getUserMedicineOrders();
      setState(() {
        _orderedMedicines = orders;
      });
    } catch (e) {
      debugPrint('Error loading ordered medicines: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingOrders = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kBackgroundGradient),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Order History",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: RefreshIndicator(
            onRefresh: _loadOrderedMedicines,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _isLoadingOrders
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : OrderedMedicinesCard(
                        orderedMedicines: _orderedMedicines,
                        onRefresh: _loadOrderedMedicines,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
