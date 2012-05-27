// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

interface Context {

  /**
   * Returns the data buffer.
   */
  Buffer getBuffer();

  /**
   * Returns the current position.
   */
  int getPosition();

  /**
   * Constructs a successful parse result.
   */
  Context success(Object result, [int position]);

  /**
   * Constructs a parse failure.
   */
  Context failure(String message, [int position]);

}

interface Result extends Context {

  /**
   * Tests if the receiver is a success.
   */
  bool isSuccess();

  /**
   * Tests if the receiver is a failure.
   */
  bool isFailure();

  /**
   * Returns the result of this parse context.
   */
  Dynamic get();

  /**
   * Returns the message of this parse context.
   */
  String getMessage();

}

interface Success extends Result { }

interface Failure extends Result { }
