import 'package:flutter/material.dart';

class Transaction extends StatelessWidget {
  final String price;
  final String title;
  final Function delete;
  final DateTime date;
  final int id;

  const Transaction(
    this.id,
    this.price,
    this.title,
    this.delete,
    this.date, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.all(10),
      height: 70,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 239, 239, 239),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '₹$price',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${date.day}/${date.month}/${date.year}",
                    style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 92, 92, 92)),
                  ),
                ],
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: ElevatedButton.icon(
              onPressed: () => delete(id),
              icon: const Icon(Icons.delete),
              label: const SizedBox.shrink(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.all(10),
                shape: const CircleBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
