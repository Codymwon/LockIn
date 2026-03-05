import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
    0: PhosphorIconsDuotone.drop,
    1: PhosphorIconsDuotone.plant,
    3: PhosphorIconsDuotone.fire,
    7: PhosphorIconsDuotone.flame,
    14: PhosphorIconsDuotone.shieldCheck,
    30: PhosphorIconsDuotone.lightning,
    60: PhosphorIconsDuotone.rocketLaunch,
    90: PhosphorIconsDuotone.diamond,
    180: PhosphorIconsDuotone.star,
    365: PhosphorIconsDuotone.crown,
  };

  // ─── Achievement Definitions ───
  // Types: 'streak' (days), 'activity' (counts), 'time' (special)
  static const List<Map<String, dynamic>> achievements = [
    // ─── Streak Badges ───
    {
      'id': 'first_day',
      'title': 'First Day',
      'description': 'Complete your first day',
      'days': 1,
      'type': 'streak',
      'icon': PhosphorIconsDuotone.plant,
    },
    {
      'id': 'three_days',
      'title': '3 Day Starter',
      'description': 'Reach a 3-day streak',
      'days': 3,
      'type': 'streak',
      'icon': PhosphorIconsDuotone.tree,
    },
    {
      'id': 'five_days',
      'title': '5 Day Focus',
      'description': 'Your first work week conquered',
      'days': 5,
      'type': 'streak',
      'icon': PhosphorIconsDuotone.target,
    },
    {
      'id': 'one_week',
      'title': '7 Day Warrior',
      'description': 'Survive an entire week',
      'days': 7,
      'type': 'streak',
      'icon': PhosphorIconsDuotone.shield,
    },
    {
      'id': 'two_weeks',
      'title': '14 Day Fighter',
      'description': 'Two weeks of discipline',
      'days': 14,
      'type': 'streak',
      'icon': PhosphorIconsDuotone.shieldCheck,
    },
    {
      'id': 'twenty_one_days',
      'title': '21 Day Habit',
      'description': 'They say 21 days builds a habit',
      'days': 21,
      'type': 'streak',
      'icon': PhosphorIconsDuotone.brain,
    },
    {
      'id': 'one_month',
      'title': '30 Day Master',
      'description': 'A full month of control',
      'days': 30,
      'type': 'streak',
      'icon': PhosphorIconsDuotone.medal,
    },
    {
      'id': 'forty_five',
      'title': '45 Day Halfway',
      'description': 'Halfway to legend status',
      'days': 45,
      'type': 'streak',
      'icon': PhosphorIconsDuotone.mapTrifold,
    },
    {
      'id': 'sixty_days',
      'title': '60 Day Veteran',
      'description': 'Two months strong',
      'days': 60,
      'type': 'streak',
      'icon': PhosphorIconsDuotone.diamond,
    },
    {
      'id': 'ninety_days',
      'title': '90 Day Legend',
      'description': 'The ultimate milestone',
      'days': 90,
      'type': 'streak',
      'icon': PhosphorIconsDuotone.trophy,
    },
    {
      'id': 'one_twenty',
      'title': '120 Day Centurion',
      'description': 'Four months of iron will',
      'days': 120,
      'type': 'streak',
      'icon': PhosphorIconsDuotone.shieldStar,
    },
    {
      'id': 'half_year',
      'title': '180 Day Titan',
      'description': 'Half a year of strength',
      'days': 180,
      'type': 'streak',
      'icon': PhosphorIconsDuotone.star,
    },
    {
      'id': 'two_seventy',
      'title': '270 Day Marathon',
      'description': 'Nine months. Born again.',
      'days': 270,
      'type': 'streak',
      'icon': PhosphorIconsDuotone.circlesFour,
    },
    {
      'id': 'one_year',
      'title': '365 Day Immortal',
      'description': 'A full year. Unstoppable.',
      'days': 365,
      'type': 'streak',
      'icon': PhosphorIconsDuotone.crown,
    },

    // ─── Activity Badges ───
    {
      'id': 'urge_slayer',
      'title': 'Urge Slayer',
      'description': 'Survive your first urge',
      'type': 'activity',
      'requirement': 1,
      'category': 'urge',
      'icon': PhosphorIconsDuotone.heartbeat,
    },
    {
      'id': 'five_urges',
      'title': '5 Urges Conquered',
      'description': 'Beat 5 urges — getting stronger',
      'type': 'activity',
      'requirement': 5,
      'category': 'urge',
      'icon': PhosphorIconsDuotone.barbell,
    },
    {
      'id': 'journaler',
      'title': 'Journaler',
      'description': 'Write your first journal entry',
      'type': 'activity',
      'requirement': 1,
      'category': 'journal',
      'icon': PhosphorIconsDuotone.pencilLine,
    },
    {
      'id': 'consistent_writer',
      'title': 'Consistent Writer',
      'description': 'Write 10 journal entries',
      'type': 'activity',
      'requirement': 10,
      'category': 'journal',
      'icon': PhosphorIconsDuotone.bookOpenText,
    },
    {
      'id': 'comeback_king',
      'title': 'Comeback King',
      'description': 'Start a new streak after a relapse',
      'type': 'activity',
      'requirement': 1,
      'category': 'relapse',
      'icon': PhosphorIconsDuotone.arrowClockwise,
    },

    // ─── Time-Based Badges ───
    {
      'id': 'night_owl',
      'title': 'Night Owl',
      'description': 'Survive an urge after midnight',
      'type': 'time',
      'timeCheck': 'night',
      'icon': PhosphorIconsDuotone.moonStars,
    },
    {
      'id': 'early_riser',
      'title': 'Early Riser',
      'description': 'Log a journal before 8 AM',
      'type': 'time',
      'timeCheck': 'morning',
      'icon': PhosphorIconsDuotone.sun,
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
