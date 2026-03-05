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
    1: PhosphorIconsDuotone.sparkle,
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
  static const List<Map<String, dynamic>> achievements = [
    {
      'id': 'first_day',
      'title': 'First Day',
      'description': 'Complete your first day',
      'days': 1,
      'icon': PhosphorIconsDuotone.plant,
    },
    {
      'id': 'three_days',
      'title': '3 Day Starter',
      'description': 'Reach a 3-day streak',
      'days': 3,
      'icon': PhosphorIconsDuotone.tree,
    },
    {
      'id': 'one_week',
      'title': '7 Day Warrior',
      'description': 'Survive an entire week',
      'days': 7,
      'icon': PhosphorIconsDuotone.shield,
    },
    {
      'id': 'two_weeks',
      'title': '14 Day Fighter',
      'description': 'Two weeks of discipline',
      'days': 14,
      'icon': PhosphorIconsDuotone.shieldCheck,
    },
    {
      'id': 'one_month',
      'title': '30 Day Master',
      'description': 'A full month of control',
      'days': 30,
      'icon': PhosphorIconsDuotone.medal,
    },
    {
      'id': 'sixty_days',
      'title': '60 Day Veteran',
      'description': 'Two months strong',
      'days': 60,
      'icon': PhosphorIconsDuotone.diamond,
    },
    {
      'id': 'ninety_days',
      'title': '90 Day Legend',
      'description': 'The ultimate milestone',
      'days': 90,
      'icon': PhosphorIconsDuotone.trophy,
    },
    {
      'id': 'half_year',
      'title': '180 Day Titan',
      'description': 'Half a year of strength',
      'days': 180,
      'icon': PhosphorIconsDuotone.star,
    },
    {
      'id': 'one_year',
      'title': '365 Day Immortal',
      'description': 'A full year. Unstoppable.',
      'days': 365,
      'icon': PhosphorIconsDuotone.crown,
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
