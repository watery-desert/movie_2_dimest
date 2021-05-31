import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'movies_card/movies_card.dart';
import 'background_image_slide.dart';
import 'movie_info_view/top_image_view.dart';
import 'movie_info_view/more_info_card.dart';
import '../widget/app_bar/transparent_appbar.dart';
import '../widget/button/movie_button.dart';
import '../seat_booking_screen/seat_booking_screen.dart';
import '../../bloc/movie_bloc.dart';

import '../error_screen/error_screen.dart';
import '../loading_screen/loading_screen.dart';

class MovieListScreen extends StatefulWidget {
  MovieListScreen();

  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  bool compactView = true;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: 0, viewportFraction: 0.8);
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocBuilder<MovieBloc, MovieState>(
          builder: (context, state) {
            if (state is MovieLoading) {
              return LoadingScreen();
            } else if (state is MovieLoaded) {
              final movies = state.movies;
              final reversedMovieList = movies.reversed.toList();

              return Stack(
                children: <Widget>[
                  if (compactView)
                    Stack(
                      children: reversedMovieList.map((movie) {
                        return BackgroundImageSlide(
                          pageController: _pageController,
                          deviceWidth: deviceWidth,
                          imageURL: movie.location,
                          backgroundIndex: movie.index,
                        );
                      }).toList(),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.white],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.3, 0.8]),
                    ),
                  ),
                  TopImageView(
                    showCompactImageView: !compactView,
                    leftImageURL: currentIndex == 0
                        ? null
                        : movies[currentIndex - 1].location,
                    middleImageURL: movies[currentIndex].location,
                    rightImageURL: currentIndex + 1 == movies.length
                        ? null
                        : movies[currentIndex + 1].location,
                  ),
                  MoreInfoCard(
                    showMoreInfo: !compactView,
                    movie: movies[currentIndex],
                  ),
                  MoviesCard(
                    showCards: compactView,
                    pageController: _pageController,
                    movieList: movies,
                    onTapCard: () {
                      setState(() {
                        compactView = false;
                      });
                    },
                    onPageChangeCallback: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                  ),
                  TransparentAppBar(),
                  Positioned(
                    bottom: 32.0,
                    left: 0.0,
                    right: 0.0,
                    child: OpenContainer(
                      transitionDuration: Duration(milliseconds: 800),
                      closedColor: Colors.transparent,
                      closedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      closedElevation: 0.0,
                      tappable: true,
                      closedBuilder: (context, action) {
                        return MovieButton(
                          title: 'BUY TICKET',
                          color: Colors.black87,
                          padding: compactView
                              ? const EdgeInsets.symmetric(horizontal: 62.0)
                              : EdgeInsets.symmetric(horizontal: 16),
                        );
                      },
                      openShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                      openColor: Colors.transparent,
                      openElevation: 0.0,
                      openBuilder: (context, action) => SeatBookingScreen(
                        movies[currentIndex],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return ErrorScreen();
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
