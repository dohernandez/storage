package storage_test

import (
	"context"
	"embed"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/dohernandez/storage"
	"github.com/dohernandez/storage/postgres"
)

//go:embed postgres/testdata/migrations/*.sql
var migrations embed.FS

type testRepo struct {
	db *storage.DB
}

func (r *testRepo) insert(ctx context.Context, id string, timestamp time.Time) error {
	_, err := r.db.ExecContext(ctx, "INSERT INTO tests (id, timestamp) VALUES ($1, $2)",
		id, timestamp)

	return err
}

func (r *testRepo) count(ctx context.Context) (int, error) {
	var count int

	err := r.db.QueryRowContext(ctx, "SELECT COUNT(*) FROM tests").Scan(&count)
	if err != nil {
		return 0, err
	}

	return count, nil
}

func (r *testRepo) all(ctx context.Context) (map[string]time.Time, error) {
	rows, err := r.db.QueryContext(ctx, "SELECT * FROM tests")
	if err != nil {
		return nil, err
	}

	all := make(map[string]time.Time, 0)

	for rows.Next() {
		var (
			ID        string
			timestamp time.Time
		)

		err = rows.Scan(&ID, &timestamp)
		if err != nil {
			return nil, err
		}

		all[ID] = timestamp
	}

	return all, nil
}

func TestDB(t *testing.T) {
	conn, err := postgres.ConnectForTesting(t, migrations)
	require.NoError(t, err)
	require.NotNil(t, conn)

	db := storage.MakeDB(conn)

	tRepo := testRepo{
		db: db,
	}

	ID := uuid.NewString()

	err = tRepo.insert(context.Background(), ID, time.Now())
	require.NoError(t, err)

	count, err := tRepo.count(context.Background())
	require.NoError(t, err)
	require.Equal(t, 1, count)

	err = tRepo.insert(context.Background(), ID, time.Now())
	require.Error(t, err)

	all, err := tRepo.all(context.Background())
	require.NoError(t, err)

	assert.Len(t, all, 1)
}

func TestDBInTx(t *testing.T) {
	t.Parallel()

	t.Run("insert successfully", func(t *testing.T) {
		t.Parallel()

		conn, err := postgres.ConnectForTesting(t, migrations)
		require.NoError(t, err)
		require.NotNil(t, conn)

		db := storage.MakeDB(conn)

		tRepo := testRepo{
			db: db,
		}

		err = storage.InTx(context.Background(), db, func(ctx context.Context) error {
			err := tRepo.insert(ctx, uuid.NewString(), time.Now())
			require.NoError(t, err)

			err = tRepo.insert(ctx, uuid.NewString(), time.Now())
			require.NoError(t, err)

			return nil
		})
		require.NoError(t, err)

		var count int

		count, err = tRepo.count(context.Background())
		require.NoError(t, err)
		require.Equal(t, 2, count)
	})

	t.Run("insert failure", func(t *testing.T) {
		t.Parallel()

		conn, err := postgres.ConnectForTesting(t, migrations)
		require.NoError(t, err)
		require.NotNil(t, conn)

		ID := uuid.NewString()

		db := storage.MakeDB(conn)

		tRepo := testRepo{
			db: db,
		}

		err = storage.InTx(context.Background(), db, func(ctx context.Context) error {
			err = tRepo.insert(ctx, ID, time.Now())
			require.NoError(t, err)

			count, err := tRepo.count(ctx)
			require.NoError(t, err)
			require.Equal(t, 1, count)

			err = tRepo.insert(ctx, ID, time.Now())
			require.Error(t, err)

			return err
		})
		require.Error(t, err)

		var count int

		count, err = tRepo.count(context.Background())
		require.NoError(t, err)
		require.Equal(t, 0, count)
	})
}
