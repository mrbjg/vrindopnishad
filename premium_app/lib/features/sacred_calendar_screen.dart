import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../core/design_system.dart';
import '../core/spirituality_provider.dart';
import '../models/sacred_event.dart';

class SacredCalendarScreen extends ConsumerStatefulWidget {
  const SacredCalendarScreen({super.key});

  @override
  ConsumerState<SacredCalendarScreen> createState() =>
      _SacredCalendarScreenState();
}

class _SacredCalendarScreenState extends ConsumerState<SacredCalendarScreen> {
  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(
      monthlyEventsProvider((year: _selectedYear, month: _selectedMonth)),
    );
    final upcomingAsync = ref.watch(upcomingEventsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: PremiumUI.masterBackground(index: 3)),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: PremiumUI.glassCard(
                            padding: const EdgeInsets.all(10),
                            borderRadius: 14,
                            child: const Icon(Iconsax.arrow_left_2,
                                color: Colors.white, size: 20),
                          ),
                        ),
                        const Spacer(),
                        Column(
                          children: [
                            Text(
                              'SACRED CALENDAR',
                              style: PremiumTokens.sansStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                                color: PremiumTokens.saffronGlow,
                              ),
                            ),
                            Text(
                              'व्रत • उत्सव • तिथि',
                              style: GoogleFonts.spectral(
                                fontSize: 13,
                                color: Colors.white38,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const SizedBox(width: 44),
                      ],
                    ),
                  ),
                ),

                // Month Selector
                SliverToBoxAdapter(
                  child: _buildMonthSelector(),
                ),

                // Upcoming Events Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Text(
                      'UPCOMING',
                      style: PremiumTokens.sansStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                ),

                // Upcoming Events List
                upcomingAsync.when(
                  data: (events) => SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final event = events[index];
                        return _buildEventCard(event, index);
                      },
                      childCount: events.length,
                    ),
                  ),
                  loading: () => const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                            color: PremiumTokens.nebulaBlue),
                      ),
                    ),
                  ),
                  error: (e, _) => SliverToBoxAdapter(
                    child: Center(
                      child: Text('Error: $e',
                          style: const TextStyle(color: Colors.white54)),
                    ),
                  ),
                ),

                // Month Events Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Text(
                      'THIS MONTH',
                      style: PremiumTokens.sansStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                ),

                eventsAsync.when(
                  data: (events) {
                    if (events.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Iconsax.calendar_2,
                                    color: Colors.white10, size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  'No events this month',
                                  style: PremiumTokens.sansStyle(
                                      color: Colors.white24, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildEventCard(events[index], index),
                        childCount: events.length,
                      ),
                    );
                  },
                  loading: () => const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                            color: PremiumTokens.nebulaBlue),
                      ),
                    ),
                  ),
                  error: (e, _) => const SliverToBoxAdapter(
                      child: SizedBox.shrink()),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 12,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = (index + 1) == _selectedMonth;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedMonth = index + 1);
            },
            child: AnimatedContainer(
              duration: 300.ms,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? PremiumTokens.nebulaBlue
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isSelected
                      ? PremiumTokens.nebulaBlue
                      : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Text(
                months[index],
                style: PremiumTokens.sansStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : Colors.white54,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(SacredEvent event, int index) {
    final daysUntil = event.date.difference(DateTime.now()).inDays;
    final isToday = event.isToday;

    final typeColors = {
      'vrat': Colors.orangeAccent,
      'utsav': Colors.pinkAccent,
      'tithi': Colors.cyanAccent,
      'ekadashi': PremiumTokens.nebulaBlue,
      'purnima': Colors.amberAccent,
    };

    final accentColor = typeColors[event.type] ?? PremiumTokens.nebulaBlue;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: PremiumUI.etherealCard(
        padding: const EdgeInsets.all(20),
        borderRadius: 20,
        glowColor: isToday ? accentColor.withValues(alpha: 0.3) : null,
        child: Row(
          children: [
            // Date badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: accentColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${event.date.day}',
                    style: PremiumTokens.sansStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                    ),
                  ),
                  Text(
                    _monthShort(event.date.month),
                    style: PremiumTokens.sansStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: accentColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        event.typeLabel,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          color: accentColor,
                        ),
                      ),
                      if (event.description != null) ...[
                        Text(
                          ' • ',
                          style: TextStyle(color: Colors.white24),
                        ),
                        Expanded(
                          child: Text(
                            event.description!,
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              color: Colors.white38,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Countdown
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isToday
                    ? accentColor.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isToday
                    ? 'TODAY'
                    : daysUntil == 1
                        ? 'TOMORROW'
                        : '${daysUntil}d',
                style: PremiumTokens.sansStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isToday ? accentColor : Colors.white54,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 80).ms, duration: 400.ms);
  }

  String _monthShort(int month) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return months[month - 1];
  }
}
