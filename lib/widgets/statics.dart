import 'package:flutter/material.dart';
import 'package:fymemos/model/users.dart';
import 'package:fymemos/utils/datetime.dart';
import 'package:fymemos/widgets/heatmap.dart';

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
          Text(
            user?.nickname ?? "User",
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.start,
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
                  Text('Memos', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              Column(
                children: [
                  Text(
                    userStats?.tagCount.length.toString() ?? "-",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text('Tags', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              Column(
                children: [
                  Text(
                    user?.createTime?.daysToToday.toString() ?? "-",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text('Days', style: Theme.of(context).textTheme.bodyMedium),
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
