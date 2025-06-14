import 'package:flutter/material.dart';
import 'package:grad_project/teamsData/teamSheet.dart';

class HeaderCell extends StatelessWidget {
  final String text;
  final double width;
  const HeaderCell(this.text, {required this.width, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge!.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.secondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class CustomDataCell extends StatelessWidget {
  final String text;
  final double width;
  final bool bold;
  const CustomDataCell(
    this.text, {
    required this.width,
    this.bold = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

Widget teamRow(
  BuildContext context,
  Map<String, dynamic> team,
  int position, {
  Color? backgroundColor,
}) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (ctx) => TeamSheet(
                teamName: team['team'] ?? '',
                logoUrl: team['team-logo'] ?? '',
              ),
        ),
      );
    },
    child: Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          CustomDataCell('$position', width: 50),
          SizedBox(
            width: 100,
            child: Row(
              children: [
                if ((team['team-logo'] ?? '').toString().isNotEmpty)
                  Image.network(
                    team['team-logo'],
                    width: 24,
                    height: 24,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            const Icon(Icons.error, size: 20),
                  ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    team['team'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          CustomDataCell('${team['played'] ?? 0}', width: 40),
          CustomDataCell('${team['won'] ?? 0}', width: 40),
          CustomDataCell('${team['drawn'] ?? 0}', width: 40),
          CustomDataCell('${team['lost'] ?? 0}', width: 40),
          CustomDataCell('${team['goalDifference'] ?? 0}', width: 50),
          CustomDataCell('${team['points'] ?? 0}', width: 50, bold: true),
        ],
      ),
    ),
  );
}

Widget header(BuildContext context) {
  return Container(
    color: Theme.of(context).colorScheme.primary,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    child: Row(
      children: const [
        HeaderCell('Pos', width: 50),
        HeaderCell('Club', width: 100),
        HeaderCell('PL', width: 40),
        HeaderCell('W', width: 40),
        HeaderCell('D', width: 40),
        HeaderCell('L', width: 40),
        HeaderCell('GD', width: 50),
        HeaderCell('Pts', width: 50),
      ],
    ),
  );
}
