import 'package:flutter/material.dart';

import 'package:movie_app_3/bloc/get_movie_similar_bloc.dart';
import 'package:movie_app_3/model/movie.dart';
import 'package:movie_app_3/model/movie_response.dart';
import 'package:movie_app_3/screens/movie_detail_screen/movie_detail_screen.dart';
import 'package:movie_app_3/style/theme.dart' as Style;

class SimilarMovies extends StatefulWidget {
  final int id;
  SimilarMovies({Key key, @required this.id}) : super(key: key);
  @override
  _SimilarMoviesState createState() => _SimilarMoviesState(id);
}

class _SimilarMoviesState extends State<SimilarMovies> {
  final int id;
  _SimilarMoviesState(this.id);
  @override
  void initState() {
    super.initState();
    similarMoviesBloc..getSimilarMovies(id);
  }

  @override
  void dispose() {
    similarMoviesBloc..drainStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 25.0, top: 20.0),
          child: Text(
            "SIMILAR MOVIES",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        Divider(
          color: Colors.white,
          indent: 25,
          endIndent: MediaQuery.of(context).size.width * 0.7,
          thickness: 1,
        ),
        SizedBox(
          height: 5.0,
        ),
        StreamBuilder<MovieResponse>(
          stream: similarMoviesBloc.subject.stream,
          builder: (context, AsyncSnapshot<MovieResponse> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.error != null &&
                  snapshot.data.error.length > 0) {
                return _buildErrorWidget(snapshot.data.error);
              }
              return _buildHomeWidget(snapshot.data);
            } else if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error);
            } else {
              return _buildLoadingWidget();
            }
          },
        )
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
        child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 25.0,
            width: 25.0,
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 4.0,
            ),
          )
        ],
      ),
    ));
  }

  Widget _buildErrorWidget(String error) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Error occured: $error"),
      ],
    ));
  }

  Widget _buildHomeWidget(MovieResponse data) {
    List<Movie> movies = data.movies;
    if (movies.length == 0) {
      return Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: <Widget>[
                  Text(
                    "No More Movies",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            )
          ],
        ),
      );
    } else
      return Container(
        height: 300.0,
        padding: EdgeInsets.only(left: 25.0),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: movies.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0, right: 15.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MovieDetailScreen(movie: movies[index]),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Hero(
                      tag: movies[index].id,
                      child: Container(
                          width: 120.0,
                          height: 180.0,
                          decoration: new BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            shape: BoxShape.rectangle,
                            image: new DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    "https://image.tmdb.org/t/p/w200/" +
                                        movies[index].poster)),
                          )),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      width: 100,
                      child: Text(
                        movies[index].title,
                        maxLines: 2,
                        style: TextStyle(
                            height: 1.4,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 12.0),
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Chip(
                          backgroundColor: Style.Colors.secondColor,
                          label: Text(
                            "Rating:  ${movies[index].rating.toString()}",
                            style: TextStyle(
                                fontSize: 10.0,
                                fontFamily: 'Raleway',
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      );
  }
}
