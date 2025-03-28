import 'package:flutter/material.dart';
import 'package:fymemos/model/users.dart';
import 'package:fymemos/utils/datetime.dart';
import 'package:fymemos/utils/l10n.dart';
import 'package:fymemos/widgets/heatmap.dart';
import 'package:go_router/go_router.dart';

class UserStatisticWidget extends StatelessWidget {
  final UserProfile? user;
  final UserStats? userStats;
  const UserStatisticWidget({
    super.key,
    required this.user,
    required this.userStats,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12),
          Row(
            children: [
              Text(
                user?.nickname ?? "User",
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.start,
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.settings_outlined),
                onPressed: () {
                  context.push('/settings');
                },
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    userStats?.memoTimes.length.toString() ?? "-",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    context.intl.memo_memos(userStats?.memoTimes.length ?? 0),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    userStats?.tagCount.length.toString() ?? "-",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    context.intl.memo_tags(userStats?.tagCount.length ?? 0),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    user?.createTime?.daysToToday.toString() ?? "-",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    context.intl.memo_days(user?.createTime?.daysToToday ?? 0),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          HeatMap(data: userStats?.memoHeatData ?? Map(), aspectRation: 2.3),
        ],
      ),
    );
  }
}
