defmodule Joblite.Accounts do
  @moduledoc """
  Public boundary for account identity and session-token lifecycle.

  Registration validates and normalizes identity; session tokens are generated
  as opaque random values, stored only as hashes and accepted until they expire
  or are revoked. All persistence goes through the single core Repo; no web or
  LiveView dependency exists here.
  """

  import Ecto.Query, warn: false

  alias Joblite.Accounts.{User, UserToken}
  alias Joblite.Repo

  @doc "Looks up a user by email, normalizing case. Returns nil when absent."
  @spec get_user_by_email(String.t()) :: User.t() | nil
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: String.downcase(email))
  end

  @doc "Fetches a user by id or raises."
  @spec get_user!(String.t()) :: User.t()
  def get_user!(id), do: Repo.get!(User, id)

  @doc "Registers a user from email and password."
  @spec register_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc "Changeset for registration forms (create or update)."
  @spec change_user_registration(User.t(), map()) :: Ecto.Changeset.t()
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs)
  end

  @doc """
  Authenticates by email and password. Returns `{:error, :invalid_credentials}`
  for both unknown emails and wrong passwords; the unknown-email path still
  performs a dummy bcrypt verify so the two failure modes take comparable time.
  """
  @spec authenticate_by_email_password(String.t(), String.t()) ::
          {:ok, User.t()} | {:error, :invalid_credentials}
  def authenticate_by_email_password(email, password)
      when is_binary(email) and is_binary(password) do
    case get_user_by_email(email) do
      %User{hashed_password: hashed} = user ->
        if Bcrypt.verify_pass(password, hashed) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end

      nil ->
        Bcrypt.no_user_verify()
        {:error, :invalid_credentials}
    end
  end

  @doc "Generates a session token for the user. The raw token is returned once; only its hash is stored."
  @spec generate_user_session_token(User.t()) :: binary()
  def generate_user_session_token(%User{} = user) do
    {raw_token, token_struct} = UserToken.build_session_token(user)
    {:ok, _stored} = Repo.insert(token_struct)
    raw_token
  end

  @doc "Returns the user for a valid unexpired session token, or nil for unknown, revoked or expired tokens."
  @spec get_user_by_session_token(binary()) :: User.t() | nil
  def get_user_by_session_token(raw_token) when is_binary(raw_token) do
    Repo.one(UserToken.verify_session_token_query(raw_token))
  end

  @doc "Revokes a session token by deleting its stored hash. Idempotent."
  @spec delete_user_session_token(binary()) :: :ok
  def delete_user_session_token(raw_token) when is_binary(raw_token) do
    {_count, _} = Repo.delete_all(UserToken.delete_session_token_query(raw_token))
    :ok
  end
end
