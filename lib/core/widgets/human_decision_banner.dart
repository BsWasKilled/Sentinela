import 'package:flutter/material.dart';

import '../../features/alerts/domain/territory_alert.dart';
import 'info_banner.dart';

/// Aviso fixo: o app apoia, mas não substitui, a decisão humana.
class HumanDecisionBanner extends StatelessWidget {
  const HumanDecisionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoBanner(
      icon: Icons.person_outline,
      text: TerritoryAlert.humanDecisionNotice,
    );
  }
}
