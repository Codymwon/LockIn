import 'package:flutter/material.dart';

class AppConstants {
  // ─── Motivational Quotes ───
  static const List<String> quotes = [
    "Discipline equals freedom.",
    "Consistency beats motivation.",
    "Stay strong today.",
    "You're building a better version of yourself.",
    "One day at a time. One choice at a time.",
    "The pain of discipline is less than the pain of regret.",
    "Your future self will thank you.",
    "Control your mind, control your life.",
    "Strength grows in the moments you resist.",
    "Every urge you conquer is a victory.",
    "Progress, not perfection.",
    "You didn't come this far to only come this far.",
    "Break the chain of habit, build the chain of days.",
    "The strongest steel is forged in the hottest fire.",
    "Your streak is proof of your willpower.",
    "Be the person you want to become.",
    "Small wins compound into massive change.",
    "Resist today, rise tomorrow.",
  ];

  // ─── Rank Titles ───
  static const Map<int, String> ranks = {
    0: 'Recruit',
    1: 'Initiate',
    3: 'Challenger',
    7: 'Warrior',
    14: 'Fighter',
    21: 'Disciplined',
    30: 'Master',
    60: 'Veteran',
    90: 'Legend',
    180: 'Titan',
    365: 'Immortal',
  };

  // ─── Progress Icons (replaces emoji metaphors) ───
  static const Map<int, IconData> progressIcons = {
    0: Icons.water_drop_outlined,
    1: Icons.auto_awesome_outlined,
    3: Icons.local_fire_department_outlined,
    7: Icons.whatshot_rounded,
    14: Icons.whatshot_rounded,
    30: Icons.bolt_rounded,
    60: Icons.rocket_launch_rounded,
    90: Icons.diamond_rounded,
    180: Icons.electric_bolt_rounded,
    365: Icons.workspace_premium_rounded,
  };

  // ─── Achievement Definitions ───
  static const List<Map<String, dynamic>> achievements = [
    {
      'id': 'first_day',
      'title': 'First Day',
      'description': 'Complete your first day',
      'days': 1,
      'icon': Icons.eco_rounded,
    },
    {
      'id': 'three_days',
      'title': '3 Day Starter',
      'description': 'Reach a 3-day streak',
      'days': 3,
      'icon': Icons.park_rounded,
    },
    {
      'id': 'one_week',
      'title': '7 Day Warrior',
      'description': 'Survive an entire week',
      'days': 7,
      'icon': Icons.shield_rounded,
    },
    {
      'id': 'two_weeks',
      'title': '14 Day Fighter',
      'description': 'Two weeks of discipline',
      'days': 14,
      'icon': Icons.verified_user_rounded,
    },
    {
      'id': 'one_month',
      'title': '30 Day Master',
      'description': 'A full month of control',
      'days': 30,
      'icon': Icons.emoji_events_rounded,
    },
    {
      'id': 'sixty_days',
      'title': '60 Day Veteran',
      'description': 'Two months strong',
      'days': 60,
      'icon': Icons.diamond_rounded,
    },
    {
      'id': 'ninety_days',
      'title': '90 Day Legend',
      'description': 'The ultimate milestone',
      'days': 90,
      'icon': Icons.military_tech_rounded,
    },
    {
      'id': 'half_year',
      'title': '180 Day Titan',
      'description': 'Half a year of strength',
      'days': 180,
      'icon': Icons.stars_rounded,
    },
    {
      'id': 'one_year',
      'title': '365 Day Immortal',
      'description': 'A full year. Unstoppable.',
      'days': 365,
      'icon': Icons.workspace_premium_rounded,
    },
  ];

  // ─── Journal Prompts ───
  static const List<String> journalPrompts = [
    "How was today?",
    "What triggered urges?",
    "What helped you stay focused?",
    "What are you grateful for today?",
    "What's one thing you did well?",
    "How do you feel right now?",
  ];

  // ─── Breathing Exercise ───
  static const int breathInSeconds = 4;
  static const int holdSeconds = 4;
  static const int breathOutSeconds = 4;
  static const int breathingCycles = 5;

  // ─── Urge Messages ───
  static const List<String> urgeMessages = [
    "Take 10 slow breaths.\nUrges pass within 3–5 minutes.\nStay present.",
    "This feeling is temporary.\nYou are stronger than this moment.",
    "Close your eyes.\nBreathe deeply.\nRemember why you started.",
    "The urge will pass whether you give in or not.\nChoose strength.",
    "You've come too far to quit now.\nBreathe through it.",
  ];
}
