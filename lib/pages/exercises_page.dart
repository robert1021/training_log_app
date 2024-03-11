import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:training_log_app/db/database_helper.dart';
import 'package:training_log_app/models/exercise_model.dart';
import 'package:training_log_app/pages/single_exercise_page.dart';
import 'package:training_log_app/utility/user_preferences.dart';
import '../widgets/app_drawer.dart';
import 'package:training_log_app/pages/create_exercise_page.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<StatefulWidget> createState() => _ExercisePage();
}

class _ExercisePage extends State<ExercisePage> {
  final searchController = TextEditingController();
  late List<Exercise> allData = [];
  late List<Exercise> filteredData = [];
  late List<Exercise> allFavoritesData = [];
  late List<Exercise> filteredFavoritesData = [];
  late List<Exercise> allCustomData = [];
  late List<Exercise> filteredCustomData = [];
  var isLoading = true;
  var isFavoritesLoading = true;
  var isCustomLoading = true;

  @override
  void initState() {
    super.initState();

    fetchAllExerciseData();
    fetchFavoritesExerciseData();
    fetchCustomExerciseData();
  }

  // Gets all exercise data
  void fetchAllExerciseData() async {
    List<Exercise> data = await DatabaseHelper.instance.getExercises();

    setState(() {
      isLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      allData = data;
      filteredData = data;
      isLoading = false;
    });
  }

  // Gets only exercises that are favorites
  void fetchFavoritesExerciseData() async {
    List<Exercise> data = await DatabaseHelper.instance.getFavoriteExercises();

    setState(() {
      isFavoritesLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      allFavoritesData = data;
      filteredFavoritesData = data;
      isFavoritesLoading = false;
    });
  }

  // Gets only exercises that are custom
  void fetchCustomExerciseData() async {
    List<Exercise> data = await DatabaseHelper.instance.getCustomExercises();

    setState(() {
      isCustomLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      allCustomData = data;
      filteredCustomData = data;
      isCustomLoading = false;
    });
  }

  void searchExercise(String query) {
    final suggestions = allData.where((item) {
      final exerciseName = item.name.toLowerCase();
      final input = query.toLowerCase();

      return exerciseName.contains(input);
    }).toList();

    setState(() {
      filteredData = suggestions;
    });
  }

  void searchFavoriteExercise(String query) {
    final suggestions = allFavoritesData.where((item) {
      final exerciseName = item.name.toLowerCase();
      final input = query.toLowerCase();

      return exerciseName.contains(input);
    }).toList();

    setState(() {
      filteredFavoritesData = suggestions;
    });
  }

  void searchCustomExercise(String query) {
    final suggestions = allCustomData.where((item) {
      final exerciseName = item.name.toLowerCase();
      final input = query.toLowerCase();

      return exerciseName.contains(input);
    }).toList();

    setState(() {
      filteredCustomData = suggestions;
    });
  }

  Widget buildAllExercisesTab() {
    if (isLoading) {
      return const Center(
          child: SpinKitCircle(
        size: 140,
        color: Colors.blue,
      ));
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              if (!isLoading)
                Container(
                  margin: const EdgeInsets.all(10),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            filteredData = allData;
                          });
                        },
                      ),
                      hintText: 'Search exercise',
                    ),
                    onChanged: searchExercise,
                  ),
                ),
              if (!isLoading)
                Expanded(
                    child: Scrollbar(
                      child: ListView.builder(
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) {
                            final item = filteredData[index];
                            return FocusedMenuHolder(
                              blurSize: 0,
                              openWithTap: false,
                              onPressed: () {},
                              menuItems: [
                                FocusedMenuItem(
                                  title: const Text('Favorite'),
                                  backgroundColor: Colors.blueAccent,
                                  trailingIcon: const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  onPressed: () async {
                                    if (UserPreferences.getVibrate() == true) {
                                      Vibrate.feedback(FeedbackType.heavy);
                                    }
                                    // favorite the specific exercise
                                    await DatabaseHelper.instance
                                        .updateFavoriteExercise(item.id!, true);

                                    List<Exercise> data = await DatabaseHelper
                                        .instance
                                        .getExercises();
                                    List<Exercise> favoriteData =
                                        await DatabaseHelper.instance
                                            .getFavoriteExercises();

                                    setState(() {
                                      allData = data;
                                      allFavoritesData = favoriteData;
                                      filteredFavoritesData = favoriteData;
                                    });
                                  },
                                ),
                              ],
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: FutureBuilder(
                                      future: DatabaseHelper.instance
                                          .isExerciseFavorite(item.id!),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          return snapshot.data == true
                                              ? const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                )
                                              : const Icon(Icons.fitness_center);
                                        } else {
                                          return const CircularProgressIndicator();
                                        }
                                      },
                                    ),
                                    title: Text(
                                      item.name.toString(),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onTap: () {
                                      // navigate
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SingleExerciseTabs(
                                                      exercise:
                                                          item.name.toString())));
                                    },
                                  ),
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                  ),
                                ],
                              ),
                            );
                          }),
                    )),
            ],
          ),
        ),
      );
    }
  }

  Widget buildFavoritesExercisesTab() {
    if (isFavoritesLoading) {
      return const Center(
          child: SpinKitCircle(
        size: 140,
        color: Colors.blue,
      ));
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              if (!isFavoritesLoading)
                Container(
                  margin: const EdgeInsets.all(10),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            filteredFavoritesData = allFavoritesData;
                          });
                        },
                      ),
                      hintText: 'Search exercise',
                    ),
                    onChanged: searchFavoriteExercise,
                  ),
                ),
              if (!isFavoritesLoading)
                Expanded(
                    child: ListView.builder(
                        itemCount: filteredFavoritesData.length,
                        itemBuilder: (context, index) {
                          final item = filteredFavoritesData[index];
                          return FocusedMenuHolder(
                            blurSize: 0,
                            openWithTap: false,
                            onPressed: () {},
                            menuItems: [
                              FocusedMenuItem(
                                title: const Text('Unfavorite'),
                                backgroundColor: Colors.blueAccent,
                                trailingIcon: const Icon(
                                  Icons.star,
                                ),
                                onPressed: () async {
                                  if (UserPreferences.getVibrate() == true) {
                                    Vibrate.feedback(FeedbackType.heavy);
                                  }
                                  // favorite the specific exercise
                                  await DatabaseHelper.instance
                                      .updateFavoriteExercise(item.id!, false);

                                  List<Exercise> data = await DatabaseHelper
                                      .instance
                                      .getExercises();
                                  List<Exercise> favoriteData =
                                      await DatabaseHelper.instance
                                          .getFavoriteExercises();

                                  setState(() {
                                    allData = data;
                                    allFavoritesData = favoriteData;
                                    for (var i = 0;
                                        i < filteredFavoritesData.length;
                                        i++) {
                                      if (filteredFavoritesData[i].name ==
                                          item.name) {
                                        filteredFavoritesData.removeAt(i);
                                        break;
                                      }
                                    }
                                  });
                                },
                              ),
                            ],
                            child: Column(
                              children: [
                                ListTile(
                                  leading: FutureBuilder(
                                    future: DatabaseHelper.instance
                                        .isExerciseFavorite(item.id!),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        return snapshot.data == true
                                            ? const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              )
                                            : const Icon(Icons.fitness_center);
                                      } else {
                                        return const CircularProgressIndicator();
                                      }
                                    },
                                  ),
                                  title: Text(
                                    item.name.toString(),
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onTap: () {
                                    // navigate
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SingleExerciseTabs(
                                                    exercise:
                                                        item.name.toString())));
                                  },
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                ),
                              ],
                            ),
                          );
                        })),
            ],
          ),
        ),
      );
    }
  }

  Widget buildCustomExercisesTab() {
    if (isCustomLoading) {
      return const Center(
          child: SpinKitCircle(
        size: 140,
        color: Colors.blue,
      ));
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              if (!isCustomLoading)
                Container(
                  margin: const EdgeInsets.all(10),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            filteredCustomData = allCustomData;
                          });
                        },
                      ),
                      hintText: 'Search exercise',
                    ),
                    onChanged: searchCustomExercise,
                  ),
                ),
              if (!isCustomLoading)
                Expanded(
                    child: ListView.builder(
                        itemCount: filteredCustomData.length,
                        itemBuilder: (context, index) {
                          final item = filteredCustomData[index];
                          return FocusedMenuHolder(
                            blurSize: 0,
                            openWithTap: false,
                            onPressed: () {},
                            menuItems: [
                              FocusedMenuItem(
                                title: const Text('Favorite'),
                                backgroundColor: Colors.blueAccent,
                                trailingIcon: const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onPressed: () async {
                                  if (UserPreferences.getVibrate() == true) {
                                    Vibrate.feedback(FeedbackType.heavy);
                                  }
                                  // favorite the specific exercise
                                  await DatabaseHelper.instance
                                      .updateFavoriteExercise(item.id!, true);

                                  List<Exercise> data = await DatabaseHelper
                                      .instance
                                      .getExercises();
                                  List<Exercise> favoriteData =
                                      await DatabaseHelper.instance
                                          .getFavoriteExercises();

                                  List<Exercise> customData =
                                      await DatabaseHelper.instance
                                          .getCustomExercises();

                                  setState(() {
                                    allData = data;
                                    allFavoritesData = favoriteData;
                                    filteredFavoritesData = favoriteData;
                                    allCustomData = customData;
                                  });
                                },
                              ),
                            ],
                            child: Column(
                              children: [
                                ListTile(
                                  leading: FutureBuilder(
                                    future: DatabaseHelper.instance
                                        .isExerciseFavorite(item.id!),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        return snapshot.data == true
                                            ? const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              )
                                            : const Icon(Icons.fitness_center);
                                      } else {
                                        return const CircularProgressIndicator();
                                      }
                                    },
                                  ),
                                  title: Text(
                                    item.name.toString(),
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onTap: () async {
                                    // navigate
                                    await Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) =>
                                                SingleExerciseTabs(
                                                    exercise:
                                                        item.name.toString())))
                                        .then((value) {
                                      fetchAllExerciseData();
                                      fetchFavoritesExerciseData();
                                      fetchCustomExerciseData();
                                    });
                                  },
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                ),
                              ],
                            ),
                          );
                        })),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Exercises'),
          centerTitle: false,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'ALL'),
              Tab(text: 'CUSTOM'),
              Tab(text: 'FAVORITES'),
            ],
          ),
        ),
        drawer: const AppDrawer(),
        body: TabBarView(
          children: [
            buildAllExercisesTab(),
            buildCustomExercisesTab(),
            buildFavoritesExercisesTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (UserPreferences.getVibrate() == true) {
              Vibrate.feedback(FeedbackType.heavy);
            }

            // navigate
            await Navigator.of(context)
                .push(MaterialPageRoute(
              builder: (context) => const CreateExercisePage(),
            ))
                .then((value) {
              fetchAllExerciseData();
              fetchFavoritesExerciseData();
              fetchCustomExerciseData();
            });
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
