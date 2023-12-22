package storage

import (
	"context"
	"database/sql"
)

type ctxTXKey struct{}

// txToContext adds transaction to context.
func txToContext(ctx context.Context, tx *sql.Tx) context.Context {
	return context.WithValue(ctx, ctxTXKey{}, tx)
}

// txFromContext gets transaction or nil from context.
func txFromContext(ctx context.Context) *sql.Tx {
	tx, ok := ctx.Value(ctxTXKey{}).(*sql.Tx)
	if !ok {
		return nil
	}

	return tx
}

// QueryerContext is an interface that may be implemented by *sql.DB and *sql.Tx.
type QueryerContext interface {
	QueryContext(ctx context.Context, query string, args ...any) (*sql.Rows, error)
}

// QueryContext is a wrap function on top of sql.QueryContext to execute the query throughout tx (transaction)
// in case it was opened in InTx function otherwise throughout the connection.
func QueryContext(ctx context.Context, queryer QueryerContext, query string, args ...any) (*sql.Rows, error) {
	if tx := txFromContext(ctx); tx != nil {
		queryer = tx
	}

	return queryer.QueryContext(ctx, query, args...)
}

// QueryerRowContext is an interface that may be implemented by *sql.DB and *sql.Tx.
type QueryerRowContext interface {
	QueryRowContext(ctx context.Context, query string, args ...any) *sql.Row
}

// QueryRowContext is a wrap function on top of sql.QueryRowContext to execute the query throughout tx (transaction)
// in case it was opened in InTx function otherwise throughout the connection.
func QueryRowContext(ctx context.Context, queryer QueryerRowContext, query string, args ...any) *sql.Row {
	if tx := txFromContext(ctx); tx != nil {
		queryer = tx
	}

	return queryer.QueryRowContext(ctx, query, args...)
}

// ExecerContext is an interface that may be implemented by *sql.DB and *sql.Tx.
type ExecerContext interface {
	ExecContext(ctx context.Context, q string, args ...interface{}) (sql.Result, error)
}

// ExecContext is a wrap function on top of sql.ExecContext to execute the query throughout tx (transaction)
// in case it was opened in InTx function otherwise throughout the connection.
func ExecContext(ctx context.Context, execer ExecerContext, query string, args ...any) (sql.Result, error) {
	if tx := txFromContext(ctx); tx != nil {
		execer = tx
	}

	return execer.ExecContext(ctx, query, args...)
}

// Transaction handles transaction.
type Transaction func(ctx context.Context) error

// BeginnerTxContext starts a transaction.
type BeginnerTxContext interface {
	BeginTx(ctx context.Context, opts *sql.TxOptions) (*sql.Tx, error)
}

// InTx runs callback in a transaction.
//
// If the transaction already exists, it will reuse that. Otherwise, it starts a new transaction and commit or rollback
// (in case of error) at the end.
func InTx(ctx context.Context, beginner BeginnerTxContext, fn Transaction, opts ...*sql.TxOptions) error {
	tx := txFromContext(ctx)

	if tx != nil {
		return fn(ctx)
	}

	txOpts := (*sql.TxOptions)(nil)

	if len(opts) > 0 {
		txOpts = opts[0]
	}

	tx, err := beginner.BeginTx(ctx, txOpts)
	if err != nil {
		return err
	}

	// Inject the transaction into context.
	ctx = txToContext(ctx, tx)

	defer func(_ context.Context, tx *sql.Tx) {
		_ = tx.Rollback() //nolint:errcheck
	}(ctx, tx)

	if err = fn(ctx); err != nil {
		return err
	}

	return tx.Commit()
}

// DB manages database query requests.
type DB struct {
	conn *sql.DB
}

// MakeDB creates a new instance fo DB.
func MakeDB(conn *sql.DB) *DB {
	return &DB{conn: conn}
}

// QueryContext executes a query that returns rows, typically a SELECT.
func (db *DB) QueryContext(ctx context.Context, query string, args ...any) (*sql.Rows, error) {
	return QueryContext(ctx, db.conn, query, args...)
}

// QueryRowContext executes a query that is expected to return at most one row, typically a SELECT.
func (db *DB) QueryRowContext(ctx context.Context, query string, args ...any) *sql.Row {
	return QueryRowContext(ctx, db.conn, query, args...)
}

// ExecContext executes a query without returning any rows.
func (db *DB) ExecContext(ctx context.Context, query string, args ...any) (sql.Result, error) {
	return ExecContext(ctx, db.conn, query, args...)
}

// BeginTx starts a transaction.
func (db *DB) BeginTx(ctx context.Context, opts *sql.TxOptions) (*sql.Tx, error) {
	return db.conn.BeginTx(ctx, opts)
}

// InTx starts a transaction.
func (db *DB) InTx(ctx context.Context, fn Transaction, opts ...*sql.TxOptions) error {
	return InTx(ctx, db.conn, fn, opts...)
}
