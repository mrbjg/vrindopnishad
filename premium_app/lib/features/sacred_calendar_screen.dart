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
          Positioned.fill(child: PremiumUI.masterBackground(index: 3, context: context)),
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
                            child: Icon(Iconsax.arrow_left_2,
                                color: PremiumTokens.textPrimary, size: 20),
                          ),
                        ),
                        const Spacer(),
                        Column(
                          children: [
                            PremiumUI.silverText(
                              'CELESTIAL ALIGNMENT',
                              style: PremiumTokens.sansStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'व्रत • उत्सव • तिथि',
                              style: GoogleFonts.spectral(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: PremiumTokens.textMuted,
                                letterSpacing: 1,
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
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                        color: PremiumTokens.textSecondary,
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
                  loading: () => SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                            color: PremiumTokens.textPrimary),
                      ),
                    ),
                  ),
                  error: (e, _) => SliverToBoxAdapter(
                    child: Center(
                      child: Text('Error: $e',
                          style: TextStyle(color: PremiumTokens.textMuted)),
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
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                        color: PremiumTokens.textSecondary,
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
                                 Icon(Iconsax.calendar_2,
                                    color: PremiumTokens.borderSubtle, size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  'No events this month',
                                  style: PremiumTokens.sansStyle(
                                      color: PremiumTokens.textMuted, 
                                      fontSize: 12,
                                      letterSpacing: 3,
                                  ),
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
                  loading: () => SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                            color: PremiumTokens.textPrimary),
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
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? PremiumTokens.activeAccent.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? PremiumTokens.activeAccent.withValues(alpha: 0.3)
                      : PremiumTokens.borderSubtle.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  months[index].toUpperCase(),
                  style: PremiumTokens.sansStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                    letterSpacing: 2,
                    color: isSelected ? PremiumTokens.activeAccent : PremiumTokens.textMuted,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(SacredEvent event, int index) {
    final todayDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
    final daysUntil = eventDate.difference(todayDate).inDays;
    final isToday = event.isToday;

    final typeColors = {
      'vrat': Colors.orangeAccent,
      'utsav': Colors.pinkAccent,
      'tithi': Colors.cyanAccent,
      'ekadashi': PremiumTokens.activeAccent,
      'purnima': Colors.amberAccent,
    };

    final accentColor = typeColors[event.type] ?? PremiumTokens.activeAccent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: PremiumUI.etherealCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 24,
        glowColor: isToday ? accentColor.withValues(alpha: 0.3) : null,
        child: Row(
          children: [
            // Styled Date Badge
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor.withValues(alpha: 0.15),
                    accentColor.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentColor.withValues(alpha: 0.2)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${event.date.day}',
                    style: PremiumTokens.sansStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: PremiumTokens.textPrimary,
                    ),
                  ),
                  Text(
                    _monthShort(event.date.month),
                    style: PremiumTokens.sansStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: accentColor,
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
                    style: PremiumTokens.sansStyle(
                      color: PremiumTokens.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          event.typeLabel.toUpperCase(),
                          style: PremiumTokens.sansStyle(
                            fontSize: 8,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w900,
                            color: accentColor,
                          ),
                        ),
                      ),
                      if (event.description != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event.description!,
                            style: PremiumTokens.sansStyle(
                              fontSize: 11,
                              color: PremiumTokens.textMuted,
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
            // Countdown / Today Badge
            if (isToday)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Iconsax.calendar_tick, color: accentColor, size: 16),
              ).animate(onPlay: (controller) => controller.repeat())
               .shimmer(duration: 2.seconds, color: PremiumTokens.textHint)
            else
              Text(
                daysUntil == 1 ? 'TOMORROW' : '${daysUntil}d',
                style: PremiumTokens.sansStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: PremiumTokens.textHint,
                  letterSpacing: 1,
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 60).ms, duration: 400.ms).slideY(begin: 0.05);
  }

  String _monthShort(int month) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return months[month - 1];
  }
}
